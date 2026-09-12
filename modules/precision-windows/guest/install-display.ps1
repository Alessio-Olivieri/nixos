# Install the bounded Gaming sign-in display repair. Apply only the existing
# Looking Glass path, without persisting topology. No credentials/input handling.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$directory = Join-Path $env:ProgramData 'PrecisionWindowsDisplay'
if (-not (Test-Path $directory)) { New-Item -ItemType Directory -Path $directory | Out-Null }
if ((Get-Item $directory).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Refusing a reparse-point installation directory' }
$acl = New-Object System.Security.AccessControl.DirectorySecurity
$acl.SetAccessRuleProtection($true, $false)
foreach ($sid in @('S-1-5-18', 'S-1-5-32-544')) {
    $identity = New-Object System.Security.Principal.SecurityIdentifier($sid)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($identity, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
    $acl.AddAccessRule($rule)
}
Set-Acl -Path $directory -AclObject $acl
$source = @'
using System;
using System.IO;
using System.Text;
using System.Runtime.InteropServices;
using System.ComponentModel;
public class PrecisionDisplayProbe {
    [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
    struct STARTUPINFO {
        public int cb; public string reserved, desktop, title;
        public int x,y,xSize,ySize,xCount,yCount,fill,flags;
        public short show,reserved2; public IntPtr reservedPtr,input,output,error;
    }
    [StructLayout(LayoutKind.Sequential)]
    struct PROCESS_INFORMATION { public IntPtr process,thread; public uint pid,tid; }
    [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
    struct DISPLAY_DEVICE {
        public int cb;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string name;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst=128)] public string description;
        public uint flags;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst=128)] public string id;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst=128)] public string key;
    }
    [DllImport("kernel32.dll")] static extern IntPtr GetCurrentProcess();
    [DllImport("kernel32.dll")] static extern uint WTSGetActiveConsoleSessionId();
    [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr handle);
    [DllImport("kernel32.dll")] static extern uint WaitForSingleObject(IntPtr handle, uint timeout);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool GetExitCodeProcess(IntPtr handle, out uint code);
    [DllImport("advapi32.dll", SetLastError=true)] static extern bool OpenProcessToken(IntPtr process, uint access, out IntPtr token);
    [DllImport("advapi32.dll", SetLastError=true)] static extern bool DuplicateTokenEx(IntPtr existing, uint access, IntPtr attributes, int level, int type, out IntPtr token);
    [DllImport("advapi32.dll", SetLastError=true)] static extern bool SetTokenInformation(IntPtr token, int type, ref uint data, int length);
    [DllImport("advapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    static extern bool CreateProcessAsUser(IntPtr token, string app, StringBuilder command, IntPtr pa, IntPtr ta, bool inherit, uint flags, IntPtr env, string cwd, ref STARTUPINFO si, out PROCESS_INFORMATION pi);
    [DllImport("user32.dll", CharSet=CharSet.Unicode)] static extern bool EnumDisplayDevices(string name, uint index, ref DISPLAY_DEVICE device, uint flags);
    [DllImport("user32.dll", SetLastError=true)] static extern IntPtr OpenInputDesktop(uint flags, bool inherit, uint access);
    [DllImport("user32.dll", SetLastError=true)] static extern bool SetThreadDesktop(IntPtr desktop);
    [DllImport("user32.dll")] static extern int GetDisplayConfigBufferSizes(uint flags, out uint paths, out uint modes);
    [DllImport("user32.dll")] static extern int QueryDisplayConfig(uint flags, ref uint paths, IntPtr pathData, ref uint modes, IntPtr modeData, IntPtr topology);
    [DllImport("user32.dll")] static extern int DisplayConfigGetDeviceInfo(IntPtr request);
    [DllImport("user32.dll")] static extern int SetDisplayConfig(uint paths, IntPtr pathData, uint modes, IntPtr modeData, uint flags);
    static void Check(bool ok) { if (!ok) throw new Win32Exception(Marshal.GetLastWin32Error()); }
    static void CheckCode(int code) { if(code != 0) throw new Win32Exception(code); }
    static void Copy(IntPtr src, IntPtr dst, int count) { byte[] data=new byte[count]; Marshal.Copy(src,data,0,count); Marshal.Copy(data,0,dst,count); }
    static void ApplyLookingGlass(string name, StreamWriter writer) {
        // Win32 DISPLAYCONFIG_PATH_INFO is72 bytes; MODE_INFO is64 bytes.
        // Operate only on a validated active source/target pair from Windows.
        uint paths, modes;
        CheckCode(GetDisplayConfigBufferSizes(2,out paths,out modes));
        if(paths==0 || paths>128 || modes==0 || modes>256) throw new Exception("Unexpected display topology size");
        IntPtr pp=Marshal.AllocHGlobal((int)paths*72), mm=Marshal.AllocHGlobal((int)modes*64);
        IntPtr request=Marshal.AllocHGlobal(84), selected=Marshal.AllocHGlobal(128);
        try {
            CheckCode(QueryDisplayConfig(2,ref paths,pp,ref modes,mm,IntPtr.Zero));
            for(uint i=0;i<paths;++i) {
                IntPtr path=IntPtr.Add(pp,(int)i*72);
                Marshal.Copy(new byte[84],0,request,84);
                Marshal.WriteInt32(request,0,1); Marshal.WriteInt32(request,4,84);
                Copy(path,IntPtr.Add(request,8),8);
                Marshal.WriteInt32(request,16,Marshal.ReadInt32(path,8));
                CheckCode(DisplayConfigGetDeviceInfo(request));
                if(Marshal.PtrToStringUni(IntPtr.Add(request,20)) != name) continue;
                int source=Marshal.ReadInt32(path,12), target=Marshal.ReadInt32(path,32);
                if(source<0 || source>=modes || target<0 || target>=modes) throw new Exception("Invalid display mode indices");
                IntPtr sm=IntPtr.Add(mm,source*64), tm=IntPtr.Add(mm,target*64);
                if(Marshal.ReadInt32(sm)!=1 || Marshal.ReadInt32(tm)!=2) throw new Exception("Unexpected display mode types");
                Copy(sm,selected,64); Copy(tm,IntPtr.Add(selected,64),64);
                Marshal.WriteInt32(selected,28,0); Marshal.WriteInt32(selected,32,0);
                Marshal.WriteInt32(path,12,0); Marshal.WriteInt32(path,32,1);
                Marshal.WriteInt32(path,68,Marshal.ReadInt32(path,68)|1);
                // APPLY | USE_SUPPLIED_DISPLAY_CONFIG | ALLOW_CHANGES; no SAVE_TO_DATABASE.
                CheckCode(SetDisplayConfig(1,path,2,selected,0x80|0x20|0x400));
                writer.WriteLine("PASS: temporary Looking Glass-only topology applied (not persisted)");
                return;
            }
            throw new Exception("No matching active Looking Glass display path");
        } finally {Marshal.FreeHGlobal(pp);Marshal.FreeHGlobal(mm);Marshal.FreeHGlobal(request);Marshal.FreeHGlobal(selected);}
    }
    public static int Main(string[] args) {
        try {
            string exe = System.Reflection.Assembly.GetExecutingAssembly().Location;
            string output = Path.Combine(Path.GetDirectoryName(exe), "displays.txt");
            if (args.Length == 1 && args[0] == "console") {
                // Attach this short-lived worker to the CURRENT input desktop;
                // never switch desktops or unlock/sign in a Windows session.
                IntPtr desktop=OpenInputDesktop(0,false,0x02000000);
                Check(desktop!=IntPtr.Zero); Check(SetThreadDesktop(desktop));
                // The OS closes the selected desktop handle when this worker exits.
                using (var writer = new StreamWriter(output)) {
                    writer.WriteLine("Session=" + System.Diagnostics.Process.GetCurrentProcess().SessionId);
                    string lookingGlass=null;
                    int active=0; bool primary=false;
                    for (uint i=0; ; ++i) {
                        DISPLAY_DEVICE device = new DISPLAY_DEVICE(); device.cb=Marshal.SizeOf(device);
                        if (!EnumDisplayDevices(null, i, ref device, 0)) break;
                        writer.WriteLine(device.name + " | " + device.description + " | flags=" + device.flags + " | " + device.id);
                        if((device.flags&1)!=0) ++active;
                        if(device.description=="Looking Glass Indirect Display Device" && (device.flags&1)!=0) {
                            if(lookingGlass!=null) throw new Exception("More than one Looking Glass display");
                            lookingGlass=device.name;
                            primary=(device.flags&4)!=0;
                        }
                    }
                    if(lookingGlass==null) throw new Exception("No active Looking Glass display; no topology change");
                    if(active==1 && primary) writer.WriteLine("PASS: Looking Glass already the only active display; no change");
                    else ApplyLookingGlass(lookingGlass,writer);
                }
                return 0;
            }
            uint session = WTSGetActiveConsoleSessionId();
            if (session == 0 || session == 0xffffffff) throw new Exception("No interactive console session");
            IntPtr original=IntPtr.Zero, token=IntPtr.Zero;
            try {
                Check(OpenProcessToken(GetCurrentProcess(), 0x0002|0x0008, out original));
                Check(DuplicateTokenEx(original, 0x02000000, IntPtr.Zero, 2, 1, out token));
                Check(SetTokenInformation(token, 12, ref session, 4));
                STARTUPINFO si=new STARTUPINFO(); si.cb=Marshal.SizeOf(si); si.desktop="winsta0\\winlogon";
                PROCESS_INFORMATION pi;
                Check(CreateProcessAsUser(token, exe, new StringBuilder("\"" + exe + "\" console"), IntPtr.Zero, IntPtr.Zero, false, 0x08000000, IntPtr.Zero, Path.GetDirectoryName(exe), ref si, out pi));
                try {
                    if (WaitForSingleObject(pi.process, 15000) != 0) throw new Exception("Display probe timed out; inspect before retrying");
                    uint code; Check(GetExitCodeProcess(pi.process,out code));
                    if(code!=0) throw new Exception("Console display operation failed with exit " + code);
                } finally { CloseHandle(pi.thread); CloseHandle(pi.process); }
            } finally { if(token!=IntPtr.Zero)CloseHandle(token); if(original!=IntPtr.Zero)CloseHandle(original); }
            Console.WriteLine(File.ReadAllText(output));
            return 0;
        } catch(Exception e) {
            string message="ERROR: " + e.ToString(); Console.WriteLine(message);
            try { File.AppendAllText(Path.Combine(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location),"errors.txt"),message+Environment.NewLine); } catch {}
            return 1;
        }
    }
}
'@
$hash = [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($source))).Replace('-','').Substring(0,16)
$executable = Join-Path $directory ("DisplayTopology-$hash.exe")
if (-not (Test-Path $executable)) { Add-Type -TypeDefinition $source -OutputAssembly $executable -OutputType ConsoleApplication }
[IO.File]::WriteAllText((Join-Path $directory "DisplayTopology-$hash.cs"), $source)
& $executable
if ($LASTEXITCODE -ne 0) { throw "Console display probe failed: $LASTEXITCODE (files retained at $directory)" }
$startup = @'
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$directory = 'C:\ProgramData\PrecisionWindowsDisplay'
$log = Join-Path $directory 'startup.log'
$executable = Join-Path $directory 'DISPLAY_EXECUTABLE'
try {
    [IO.File]::WriteAllText($log, "Started $([DateTime]::Now.ToString('o'))`r`n")
    # Light has no passed-through NVIDIA: never alter its QXL display.
    $gpu = @(Get-PnpDevice -PresentOnly | Where-Object InstanceId -Like 'PCI\VEN_10DE&DEV_24B7*')
    if ($gpu.Count -eq 0) { Add-Content $log 'Light / no NVIDIA: no display changes'; exit 0 }
    if ($gpu.Count -ne 1) { throw 'Unexpected NVIDIA topology' }
    $deadline = [DateTime]::UtcNow.AddSeconds(75)
    do {
        $gpu = Get-PnpDevice -InstanceId $gpu[0].InstanceId
        if ($gpu.Status -eq 'OK') {
            $result = & $executable 2>&1
            $code = $LASTEXITCODE
            Add-Content $log ($result | Out-String)
            if ($code -eq 0) { Add-Content $log 'PASS: Gaming sign-in display ready'; exit 0 }
        }
        Start-Sleep -Seconds 2
    } while ([DateTime]::UtcNow -lt $deadline)
    throw 'Gaming display did not become ready within the bounded startup window'
} catch { Add-Content $log ($_ | Out-String); exit 1 }
'@
$startup = $startup.Replace('DISPLAY_EXECUTABLE', [IO.Path]::GetFileName($executable))
$startupPath = Join-Path $directory 'startup.ps1'
[IO.File]::WriteAllText($startupPath, $startup)
$action = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$startupPath`""
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 2) -MultipleInstances IgnoreNew
$triggers = @((New-ScheduledTaskTrigger -AtStartup))
Register-ScheduledTask -TaskName 'Precision Windows Gaming Display' -Description 'Route Gaming sign-in to Looking Glass; skip Light; no saved topology or automatic login.' -Action $action -Trigger $triggers -Settings $settings -User 'SYSTEM' -RunLevel Highest -Force | Select-Object TaskName,State | ConvertTo-Json
Get-FileHash -Algorithm SHA256 $executable,$startupPath | Select-Object Path,Hash | ConvertTo-Json
Write-Output "Installed display repair: $directory (SYSTEM/Administrators only)"
