# Windows Gaming sign-in display fix

## Why this guest-side helper exists

On generation154, a cold Gaming boot could have a healthy A4000 and pass an actual CUDA kernel while Looking Glass received an entirely black frame. Console-session enumeration showed QXL primary and Looking Glass secondary. Before a user signed in, the upstream Looking Glass helper could not obtain a user token to apply its normal exclusive-display layout.

Applying the same temporary Looking Glass-only layout from a short-lived SYSTEM worker in the current console desktop produced a real Looking Glass frame containing the Windows lock screen. No sign-in, password, account policy, firmware or TPM changes were made. The display database is deliberately NOT updated: the pinned upstream driver warns that persisting an IDD-only topology can create a boot dependency cycle.

## Reproducibility boundary

Linux remains Nix-managed in this worktree. This Windows change is scripted provisioning of the existing guest, not a Nix-managed Windows installation.

With Gaming running, its NVIDIA driver healthy and QEMU Guest Agent available, install or reconcile the helper using:

```sh
python3 maintenance/guest-agent.py maintenance/guest-display-console.ps1
```

The reviewed C# source is embedded in that installer and also saved alongside the compiled executable inside Windows. A source-hash-derived executable name permits repeat installation. The script registers the same named task rather than creating duplicates.

- Task: `Precision Windows Gaming Display`, triggered at Windows startup only.
- Files: `C:\ProgramData\PrecisionWindowsDisplay`, writable only by SYSTEM and Administrators.
- Light: if NVIDIA is absent, exit without changing the QXL layout.
- Gaming: wait up to75seconds for a healthy A4000 and an active Looking Glass display; apply that existing path without saving topology. Exit immediately if Looking Glass is already the only active primary display.
- The task has a two-minute execution limit, no restart loop, and identical behavior on battery and AC. It is a permanent display component, not an unattended-maintenance privilege or auto-login service.
- The console worker attaches only itself to the current input desktop. It does not switch desktops, type input, unlock Windows or handle credentials. Its privileged token and desktop handles die with the short-lived worker.
- The PowerShell execution policy override is limited to the task process and reviewed administrative script. Machine and user execution policies are unchanged.

Logs: `startup.log`, `displays.txt`, and any `errors.txt` in that folder. A nonzero task result is a failed test, not success. The maintenance script transport uses a private temporary guest directory and removes the staged script after execution.

## Removal

From an elevated Windows PowerShell, disable/remove only the named task:

```powershell
Unregister-ScheduledTask -TaskName 'Precision Windows Gaming Display' -Confirm:$false
```

The next Windows boot uses its saved display topology; no topology rollback is required. The protected `C:\ProgramData\PrecisionWindowsDisplay` folder contains only this helper's code and logs and can then be archived or removed. Do not disable/uninstall QXL or change Windows auto-login to work around a black Gaming sign-in screen.

Actual fresh-boot results are recorded separately in `GENERATION-154-VALIDATION.md`; installation alone is not proof that the startup task worked.
