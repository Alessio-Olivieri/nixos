# Install the Gaming display selector. No mirroring, login or driver changes.
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
$users = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-32-545')
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($users,'ReadAndExecute','ContainerInherit,ObjectInherit','None','Allow')))
Set-Acl -Path $directory -AclObject $acl
$choicePath = Join-Path $directory 'choice.txt'
if (Test-Path $choicePath) {
    if ((Get-Item $choicePath).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Refusing reparse-point preference' }
} else { [IO.File]::WriteAllText($choicePath, 'laptop') }
# Users can change only the literal preference file, not replace it or alter
# executables/tasks. SYSTEM accepts only laptop/hdmi, never commands or paths.
$choiceAcl = Get-Acl $choicePath
$choiceAcl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($users,'Write','Allow')))
Set-Acl $choicePath $choiceAcl
$source = @'
using System;
using System.IO;
using System.Text;
using System.Runtime.InteropServices;
using System.ComponentModel;
using System.Collections.Generic;
using System.Threading;
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
    [DllImport("user32.dll")] static extern bool CloseDesktop(IntPtr desktop);
    [DllImport("user32.dll")] static extern int GetDisplayConfigBufferSizes(uint flags, out uint paths, out uint modes);
    [DllImport("user32.dll")] static extern int QueryDisplayConfig(uint flags, ref uint paths, IntPtr pathData, ref uint modes, IntPtr modeData, IntPtr topology);
    [DllImport("user32.dll")] static extern int DisplayConfigGetDeviceInfo(IntPtr request);
    [DllImport("user32.dll")] static extern int SetDisplayConfig(uint paths, IntPtr pathData, uint modes, IntPtr modeData, uint flags);
    static void Check(bool ok) { if (!ok) throw new Win32Exception(Marshal.GetLastWin32Error()); }
    static void CheckCode(int code) { if(code != 0) throw new Win32Exception(code); }
    static void Copy(IntPtr src, IntPtr dst, int count) { byte[] data=new byte[count]; Marshal.Copy(src,data,0,count); Marshal.Copy(data,0,dst,count); }
    static string DirectoryName { get { return Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location); } }
    static string ReadChoice() {
        using(var file=new FileStream(Path.Combine(DirectoryName,"choice.txt"),FileMode.Open,FileAccess.Read,FileShare.ReadWrite)) {
            if(file.Length>16) throw new Exception("Invalid display preference size");
            using(var reader=new StreamReader(file)) {
                string choice=reader.ReadToEnd().Trim();
                if(choice!="laptop" && choice!="hdmi") throw new Exception("Invalid display preference");
                return choice;
            }
        }
    }
    sealed class Topology : IDisposable {
        public uint paths,modes; public IntPtr pp,mm;
        public Topology(uint flags) {
            for(int attempt=0;attempt<3;++attempt) {
                CheckCode(GetDisplayConfigBufferSizes(flags,out paths,out modes));
                if(paths>512 || modes>1024) throw new Exception("Unexpected topology size");
                pp=Marshal.AllocHGlobal((int)Math.Max(paths,1)*72); mm=Marshal.AllocHGlobal((int)Math.Max(modes,1)*64);
                int code=QueryDisplayConfig(flags,ref paths,pp,ref modes,mm,IntPtr.Zero);
                if(code==0) return;
                Dispose(); if(code!=122) CheckCode(code);
            }
            throw new Exception("Display topology changed during query");
        }
        public IntPtr PathAt(uint i) { return IntPtr.Add(pp,(int)i*72); }
        public void Dispose() { if(pp!=IntPtr.Zero) Marshal.FreeHGlobal(pp); if(mm!=IntPtr.Zero) Marshal.FreeHGlobal(mm); pp=mm=IntPtr.Zero; }
    }
    static string SourceName(IntPtr path) {
        IntPtr request=Marshal.AllocHGlobal(84);
        try {
            Marshal.Copy(new byte[84],0,request,84);
            Marshal.WriteInt32(request,0,1); Marshal.WriteInt32(request,4,84);
            Copy(path,IntPtr.Add(request,8),8); Marshal.WriteInt32(request,16,Marshal.ReadInt32(path,8));
            CheckCode(DisplayConfigGetDeviceInfo(request));
            return Marshal.PtrToStringUni(IntPtr.Add(request,20));
        } finally { Marshal.FreeHGlobal(request); }
    }
    static Dictionary<string,string> Adapters() {
        var adapters=new Dictionary<string,string>();
        for(uint i=0;;++i) {
            DISPLAY_DEVICE d=new DISPLAY_DEVICE(); d.cb=Marshal.SizeOf(d);
            if(!EnumDisplayDevices(null,i,ref d,0)) break;
            adapters[d.name]=d.description;
        }
        return adapters;
    }
    static string Kind(IntPtr path,Dictionary<string,string> adapters) {
        string description; if(!adapters.TryGetValue(SourceName(path),out description)) return "other";
        if(description=="Looking Glass Indirect Display Device") return "laptop";
        // Looking Glass also advertises HDMI: require the real NVIDIA adapter.
        if(description=="NVIDIA RTX A4000 Laptop GPU" && Marshal.ReadInt32(path,36)==5) return "hdmi";
        return "other";
    }
    static string TargetKey(IntPtr path) { return Marshal.ReadInt64(path,20)+":"+Marshal.ReadInt32(path,28); }
    static string failedSignature=null;
    static void Route(bool probe,StreamWriter writer) {
        var adapters=Adapters();
        if(!adapters.ContainsValue("NVIDIA RTX A4000 Laptop GPU")) { writer.WriteLine("Light: no display changes"); return; }
        string choice=ReadChoice();
        using(var current=new Topology(2)) {
            if(!probe && choice=="laptop" && current.paths==1 && Kind(current.PathAt(0),adapters)=="laptop") return;
            using(var all=new Topology(1)) {
                var targets=new Dictionary<string,IntPtr>(); var signature=new StringBuilder(choice);
                for(uint i=0;i<all.paths;++i) {
                    IntPtr p=all.PathAt(i);
                    if(Marshal.ReadInt32(p,60)==0) continue;
                    string kind=Kind(p,adapters),key=kind+":"+TargetKey(p);
                    if(!targets.ContainsKey(key)) { targets[key]=p; signature.Append("|").Append(key); }
                }
                IntPtr selected=IntPtr.Zero; string actual=choice; int count=0;
                foreach(var entry in targets) if(entry.Key.StartsWith(choice+":")) {selected=entry.Value;++count;}
                if(choice=="hdmi" && count==0) {
                    actual="laptop";
                    foreach(var entry in targets) if(entry.Key.StartsWith("laptop:")) {selected=entry.Value;++count;}
                }
                if(count!=1) throw new Exception("Expected one available "+actual+" display, found "+count+"; no change");
                if(!probe && current.paths==1 && Kind(current.PathAt(0),adapters)==actual && TargetKey(current.PathAt(0))==TargetKey(selected)) return;
                signature.Append("|").Append(File.GetLastWriteTimeUtc(Path.Combine(DirectoryName,"choice.txt")).Ticks);
                if(!probe && failedSignature==signature.ToString()) return; // No repeated failed apply.
                IntPtr candidate=Marshal.AllocHGlobal(72);
                try {
                    if(!probe) failedSignature=signature.ToString();
                    Copy(selected,candidate,72);
                    Marshal.WriteInt32(candidate,12,-1); Marshal.WriteInt32(candidate,32,-1);
                    Marshal.WriteInt32(candidate,48,0); Marshal.WriteInt32(candidate,52,0);
                    Marshal.WriteInt32(candidate,56,0);
                    Marshal.WriteInt32(candidate,68,Marshal.ReadInt32(candidate,68)|1);
                    // Best-mode selection for inactive targets; never save Windows topology.
                    CheckCode(SetDisplayConfig(1,candidate,0,IntPtr.Zero,0x40|0x20|0x400));
                    writer.WriteLine("VALIDATED: preference="+choice+", available output="+actual);
                    if(probe) return;
                    try {
                        CheckCode(SetDisplayConfig(1,candidate,0,IntPtr.Zero,0x80|0x20|0x400));
                        using(var check=new Topology(2)) {
                            if(check.paths!=1 || Kind(check.PathAt(0),Adapters())!=actual)
                                throw new Exception("Display apply did not produce the requested single output");
                        }
                    } catch {
                        if(current.paths>0) writer.WriteLine("Rollback result="+SetDisplayConfig(current.paths,current.pp,current.modes,current.mm,0x80|0x20|0x400));
                        throw;
                    }
                    failedSignature=null;
                    writer.WriteLine("APPLIED: "+actual+"; remembered="+choice);
                } finally {Marshal.FreeHGlobal(candidate);}
            }
        }
    }
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
            if(args.Length==1 && (args[0]=="laptop" || args[0]=="hdmi")) {
                // Unprivileged shortcut: modify only the pre-created scalar preference.
                using(var file=new FileStream(Path.Combine(DirectoryName,"choice.txt"),FileMode.Open,FileAccess.Write,FileShare.ReadWrite)) {
                    byte[] bytes=Encoding.ASCII.GetBytes(args[0]); file.Write(bytes,0,bytes.Length); file.SetLength(bytes.Length); file.Flush();
                }
                return 0;
            }
            if(args.Length==2 && args[0]=="console" && (args[1]=="watch" || args[1]=="probe")) {
                IntPtr last=IntPtr.Zero;
                string lastError=null;
                EventWaitHandle stop=args[1]=="watch" ? new EventWaitHandle(false,EventResetMode.ManualReset,"Global\\PrecisionWindowsDisplayStop") : null;
                if(stop!=null) stop.Reset();
                using(var writer=new StreamWriter(Path.Combine(DirectoryName,args[1]=="probe" ? "selection-probe.log" : "selection.log"),true)) {
                    writer.AutoFlush=true;
                    do {
                        try {
                            IntPtr desktop=OpenInputDesktop(0,false,0x02000000);
                            Check(desktop!=IntPtr.Zero);
                            if(!SetThreadDesktop(desktop)) {CloseDesktop(desktop);Check(false);}
                            if(last!=IntPtr.Zero) CloseDesktop(last); last=desktop;
                            Route(args[1]=="probe",writer);
                        } catch(Exception error) { if(error.Message!=lastError) writer.WriteLine(DateTime.UtcNow.ToString("o")+" ERROR: "+error.Message); lastError=error.Message; if(args[1]=="probe") throw; }
                        if(args[1]=="probe") break;
                        if(stop.WaitOne(3000)) break;
                    } while(true);
                }
                if(stop!=null) stop.Dispose();
                return 0;
            }
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
                string operation=args.Length==1 && args[0]=="probe" ? "probe" : "watch";
                Check(CreateProcessAsUser(token, exe, new StringBuilder("\"" + exe + "\" console "+operation), IntPtr.Zero, IntPtr.Zero, false, 0x08000000, IntPtr.Zero, Path.GetDirectoryName(exe), ref si, out pi));
                try {
                    if (WaitForSingleObject(pi.process, operation=="probe" ? 15000U : 0xffffffffU) != 0) throw new Exception("Display probe timed out; inspect before retrying");
                    uint code; Check(GetExitCodeProcess(pi.process,out code));
                    if(code!=0) throw new Exception("Console display operation failed with exit " + code);
                } finally { CloseHandle(pi.thread); CloseHandle(pi.process); }
            } finally { if(token!=IntPtr.Zero)CloseHandle(token); if(original!=IntPtr.Zero)CloseHandle(original); }
            Console.WriteLine("Display operation completed");
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
$manifestPath = Join-Path $directory 'managed-installation.json'
$version = (Get-FileHash -Algorithm SHA256 $PSCommandPath).Hash
$taskName = 'Precision Windows Gaming Display'
$oldTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
$same = $false
if ((Test-Path $manifestPath) -and (Test-Path $startupPath) -and $oldTask) {
    $managed = Get-Content $manifestPath -Raw | ConvertFrom-Json
    $same = $managed.version -eq $version -and
        $managed.executableHash -eq (Get-FileHash $executable -Algorithm SHA256).Hash -and
        $managed.startupHash -eq (Get-FileHash $startupPath -Algorithm SHA256).Hash -and
        $oldTask.Actions.Arguments -like ('*'+$startupPath+'*') -and
        $oldTask.Principal.UserId -in @('SYSTEM','S-1-5-18')
    $w = New-Object -ComObject WScript.Shell
    foreach ($entry in @(@('Windows on laptop','laptop'),@('Windows on HDMI','hdmi'))) {
        foreach ($folder in @([Environment]::GetFolderPath('CommonDesktopDirectory'),[Environment]::GetFolderPath('CommonPrograms'))) {
            $link = Join-Path $folder ($entry[0]+'.lnk')
            if (-not(Test-Path $link)) { $same=$false; continue }
            $s=$w.CreateShortcut($link)
            if ($s.TargetPath -ne $executable -or $s.Arguments -ne $entry[1]) { $same=$false }
        }
    }
}
if ($same) {
    # Repair ACLs above but leave the user's display and healthy watcher alone.
    if ($oldTask.State -ne 'Running') { Start-ScheduledTask -TaskName $taskName }
    Write-Output "UNCHANGED: managed display helper $version; preference preserved"
    exit 0
}
& $executable probe
if ($LASTEXITCODE -ne 0) { throw "Display validation failed; previous task remains intact" }
# A changed version replaces only this task, never the guest or desktop session.
$oldXml = if ($oldTask) { Export-ScheduledTask -TaskName $taskName } else { $null }
$oldStartup = if (Test-Path $startupPath) { [IO.File]::ReadAllText($startupPath) } else { $null }
$oldName = if ($oldStartup -match "DisplayTopology-[A-F0-9]{16}\.exe") { $Matches[0] } else { $null }
if ($oldTask) {
    try { $stop=[Threading.EventWaitHandle]::OpenExisting('Global\PrecisionWindowsDisplayStop'); $stop.Set() | Out-Null; $stop.Dispose(); Start-Sleep -Seconds 1 } catch [Threading.WaitHandleCannotBeOpenedException] { }
    if ($oldTask.State -eq 'Running') { Stop-ScheduledTask -TaskName $taskName }
    $deadline = [DateTime]::UtcNow.AddSeconds(10)
    do {
        $workers = @(Get-CimInstance Win32_Process | Where-Object {
            $oldName -and $_.ExecutablePath -eq (Join-Path $directory $oldName) -and $_.CommandLine -match 'console watch'
        })
        if ($workers.Count -eq 0) { break }
        Start-Sleep -Milliseconds 250
    } while ([DateTime]::UtcNow -lt $deadline)
    if ($workers.Count) {
        # One-time migration of our pre-reconciliation watcher, which had no stop
        # event and escaped Task Scheduler's process tree. No other process kill.
        if($oldName -eq 'DisplayTopology-7984130182FCE66A.exe' -and $workers.Count -eq 1) {
            $legacy=Get-CimInstance Win32_Process -Filter ("ProcessId="+$workers[0].ProcessId)
            if($legacy.ExecutablePath -ne (Join-Path $directory $oldName) -or $legacy.CreationDate -ne $workers[0].CreationDate) { throw 'Legacy watcher identity changed' }
            Stop-Process -Id $legacy.ProcessId -ErrorAction Stop
            Write-Output 'Retired legacy display watcher; Windows and its applications remain running'
        } else { throw 'Previous display watcher did not stop; refusing duplicate installation' }
    }
}
try {
if ((Test-Path $startupPath) -and -not(Test-Path (Join-Path $directory 'startup-before-output-selection.ps1'))) {
    Copy-Item $startupPath (Join-Path $directory 'startup-before-output-selection.ps1')
    Export-ScheduledTask -TaskName 'Precision Windows Gaming Display' | Set-Content (Join-Path $directory 'task-before-output-selection.xml')
}
[IO.File]::WriteAllText($startupPath, $startup)
$action = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$startupPath`""
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew
$triggers = @((New-ScheduledTaskTrigger -AtStartup))
Register-ScheduledTask -TaskName 'Precision Windows Gaming Display' -Description 'Remember laptop/HDMI output, follow unplugging; skip Light; no mirroring or automatic login.' -Action $action -Trigger $triggers -Settings $settings -User 'SYSTEM' -RunLevel Highest -Force | Select-Object TaskName,State | ConvertTo-Json
$shell = New-Object -ComObject WScript.Shell
foreach ($entry in @(@('Windows on laptop','laptop'),@('Windows on HDMI','hdmi'))) {
    foreach ($folder in @([Environment]::GetFolderPath('CommonDesktopDirectory'),[Environment]::GetFolderPath('CommonPrograms'))) {
        $shortcut = $shell.CreateShortcut((Join-Path $folder ($entry[0]+'.lnk')))
        $shortcut.TargetPath=$executable; $shortcut.Arguments=$entry[1]; $shortcut.WorkingDirectory=$directory
        $shortcut.Description='Choose where Gaming Windows appears; remembered for next time'
        $shortcut.WindowStyle=7; $shortcut.Save()
    }
}
Start-ScheduledTask -TaskName 'Precision Windows Gaming Display'
$gpu = @(Get-PnpDevice -PresentOnly | Where-Object InstanceId -Like 'PCI\VEN_10DE&DEV_24B7*')
if ($gpu.Count) {
    $deadline=[DateTime]::UtcNow.AddSeconds(12)
    do {
        $workers=@(Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath -eq $executable -and $_.CommandLine -match 'console watch' })
        if($workers.Count -eq 1) { break }
        Start-Sleep -Milliseconds 500
    } while([DateTime]::UtcNow -lt $deadline)
    if($workers.Count -ne 1) { throw 'The new display watcher did not start exactly once' }
}
@{version=$version; executableHash=(Get-FileHash $executable -Algorithm SHA256).Hash; startupHash=(Get-FileHash $startupPath -Algorithm SHA256).Hash} |
    ConvertTo-Json | Set-Content $manifestPath
Get-FileHash -Algorithm SHA256 $executable,$startupPath | Select-Object Path,Hash | ConvertTo-Json
Write-Output "RECONCILED: $version; code protected; only choice.txt user-writable"
} catch {
    Stop-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($null -ne $oldStartup) { [IO.File]::WriteAllText($startupPath,$oldStartup) }
    if ($oldXml) {
        Register-ScheduledTask -TaskName $taskName -Xml $oldXml -Force | Out-Null
        Start-ScheduledTask -TaskName $taskName
    }
    throw
}
