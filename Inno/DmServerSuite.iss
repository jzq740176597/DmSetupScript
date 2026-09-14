; ============================================================================
;  数医服务程序 (DM Server Suite) — installer
;
;  Requires Inno Setup 7.x, 64-bit edition
;    - .zip support in extractarchive is 7.x only
;    - SetupArchitecture directive is 7.x only
;
;  SAVE THIS FILE AS UTF-8 *WITH* BOM — [Code] contains Chinese literals.
;
;  Release build:   "C:\Program Files\Inno Setup 7\ISCC.exe" dmServerSuite.iss
;  Fast test build: ISCC /DFAST dmServerSuite.iss          (no compression)
;  Version bump:    ISCC /DAppVersion=1.0.1 dmServerSuite.iss
; ============================================================================

; ---------------------------------------------------------------- identity --
#define AppName        "数医服务程序"
#define AppNameEn      "DM Server Suite"
#ifndef AppVersion
  #define AppVersion   "1.0.0"
#endif
#define Publisher      "数医科技"

; ------------------------------------------------ build-machine source paths --
#define SrcHub         "F:\Github\DmServerHub\build\windows\x64\release"
#define SrcSlave       "F:\Github\DmServers\build\windows\x64\release"
#define ZipOmmo        "G:\uPub\ommo_eval_sdk_v0.21.0.zip"
#define ZipNav         "G:\uPub\dmNavEngineXYW_release_FROM_Fujian.zip"
#define ZipPhysics     "G:\uPub\dmPhysicsServerRelease-Wanli_Phx.zip"

#define ZipOmmoName    ExtractFileName(ZipOmmo)
#define ZipNavName     ExtractFileName(ZipNav)
#define ZipPhysName    ExtractFileName(ZipPhysics)

; ------------------------------------ top-level folders created under {app} --
;  These must match the real folder names the archives unpack into.
#define DirPhysics     "dmPhysicsServerRelease"
#define DirNav         "dmNavEngineXYW_release"
#define DirOmmo        "ommo_eval_sdk_v0.21.0"
#define DirSlave       "Slave"

; ------------------------------------ exe paths relative to {app}, '/' style --
;  NOTE: the ommo zip carries a top wrapper folder of the same name as the
;  SDK folder inside it, hence DirOmmo appearing twice. Confirmed on disk.
#define ExePhysics     DirPhysics + "/dmPhysicsServer-fracture.exe"
#define ExeNavSrv      DirNav     + "/dmSimNaviServer.exe"
#define ExeNavView     DirNav     + "/dmSimNaviViewer.exe"
#define ExeOmmo        DirOmmo + "/ommo_service/ommo_service_v0.21.0.exe"
#define ExeSlaveSrv    DirSlave   + "/dmSlaveDeviceNextServerWithoutLog.exe"
#define ExeSlaveView   DirSlave   + "/dmSlaveDeviceNextViewer.exe"

[Setup]
AppId={{3F7A9C41-5E82-4B06-A1D3-9C4E7B205F68}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#Publisher}
DefaultDirName={autopf}\DmServer
DefaultGroupName={#AppName}
OutputBaseFilename=DmServerSuite_Setup_{#AppVersion}_x64
OutputDir=.\Output
SetupArchitecture=x64
PrivilegesRequired=admin
WizardStyle=modern
DisableProgramGroupPage=yes

; ASCII suffix so the entry is findable in Programs and Features
UninstallDisplayName=DmServerSuite
UninstallDisplayIcon={app}\dmServerHub.exe

VersionInfoVersion={#AppVersion}
VersionInfoCompany={#Publisher}
VersionInfoDescription={#AppNameEn} Setup

; Restart Manager: ask Windows which of our files are locked, close those apps.
; This covers the install side; uninstall is handled in [Code].
CloseApplications=yes
CloseApplicationsFilter=*.exe,*.dll
RestartApplications=no

; always Simplified Chinese; English still reachable via /LANG=en
ShowLanguageDialog=no
LanguageDetectionMethod=none

#ifdef FAST
Compression=none
#else
Compression=lzma2/max
LZMADictionarySize=524288
LZMANumBlockThreads=4
SolidCompression=yes
#endif

[Languages]
Name: "cn"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"
Name: "en"; MessagesFile: "compiler:Default.isl"

[InstallDelete]
; Runs BEFORE [Files]. Clears the previous install so a replace is clean.
; Deliberately NOT wiping {app} wholesale — that would delete unins000.exe
; mid-install and orphan the Programs-and-Features entry.
Type: filesandordirs; Name: "{app}\{#DirSlave}"
Type: filesandordirs; Name: "{app}\{#DirPhysics}"
Type: filesandordirs; Name: "{app}\{#DirNav}"
Type: filesandordirs; Name: "{app}\{#DirOmmo}"
Type: files;          Name: "{app}\settings.ini"
Type: files;          Name: "{app}\*.exe"
Type: files;          Name: "{app}\*.dll"

[Files]
; --- step 2: dmServerHub release -> MainDir ---
; settings.ini is never copied; it is generated in [Code] on every install.
Source: "{#SrcHub}\*"; DestDir: "{app}"; Excludes: "settings.ini"; \
    Flags: ignoreversion recursesubdirs createallsubdirs

; --- step 3: DmServers release -> MainDir\Slave ---
Source: "{#SrcSlave}\*"; DestDir: "{app}\{#DirSlave}"; \
    Flags: ignoreversion recursesubdirs createallsubdirs

; --- steps 4-6: carry each zip to {tmp}, then extract it from there ---
; extractarchive requires an `external` source, so it cannot read a file
; compiled into setup; the carrier entry puts it on disk first. [Files]
; processes in listed order, so each extract finds its zip already present.
Source: "{#ZipOmmo}"; DestDir: "{tmp}"; \
    Flags: deleteafterinstall
Source: "{tmp}\{#ZipOmmoName}"; DestDir: "{app}"; \
    Flags: external extractarchive ignoreversion recursesubdirs createallsubdirs

Source: "{#ZipNav}"; DestDir: "{tmp}"; \
    Flags: deleteafterinstall
Source: "{tmp}\{#ZipNavName}"; DestDir: "{app}"; \
    Flags: external extractarchive ignoreversion recursesubdirs createallsubdirs

Source: "{#ZipPhysics}"; DestDir: "{tmp}"; \
    Flags: deleteafterinstall
Source: "{tmp}\{#ZipPhysName}"; DestDir: "{app}"; \
    Flags: external extractarchive ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\dmServerHub.exe"
Name: "{group}\{cm:UninstallProgram,{#AppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\dmServerHub.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"

[Registry]
Root: HKLM; Subkey: "SOFTWARE\DmServer"; ValueType: string; \
    ValueName: "InstallPath"; ValueData: "{app}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "SOFTWARE\DmServer"; ValueType: string; \
    ValueName: "Version"; ValueData: "{#AppVersion}"

[Run]
Filename: "{app}\{#DirOmmo}\VC_redist.x64_14.40.33816.0.exe"; \
    Parameters: "/install /quiet /norestart"; \
    StatusMsg: "正在安装 VC++ 运行库..."; \
    Flags: waituntilterminated; Check: NeedsVCRedist
    
Filename: "{app}\dmServerHub.exe"; Description: "{cm:LaunchProgram,{#AppName}}"; \
    Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}\{#DirSlave}"
Type: filesandordirs; Name: "{app}\{#DirPhysics}"
Type: filesandordirs; Name: "{app}\{#DirNav}"
Type: filesandordirs; Name: "{app}\{#DirOmmo}"
Type: files;          Name: "{app}\settings.ini"
Type: dirifempty;     Name: "{app}"

[Code]
function NeedsVCRedist: Boolean;
var
  Installed: Cardinal;
begin
  Result := not (RegQueryDWordValue(HKLM,
    'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Installed', Installed)
    and (Installed = 1));
end;
{ ===========================================================================
  PART 1 — running-process detection and shutdown

  Restart Manager (CloseApplications=yes) covers install, but the uninstaller
  does not use it. Without this, uninstalling while dmServerHub or any server
  is running leaves locked files behind as orphans.
  =========================================================================== }

{ Process image names to check. Keep in sync with the Exe* defines above. }
function GuardedProcesses: TArrayOfString;
begin
  SetArrayLength(Result, 7);
  Result[0] := 'dmServerHub.exe';
  Result[1] := 'dmPhysicsServer-fracture.exe';
  Result[2] := 'dmSimNaviServer.exe';
  Result[3] := 'dmSimNaviViewer.exe';
  Result[4] := 'ommo_service_v0.21.0.exe';
  Result[5] := 'dmSlaveDeviceNextServerWithoutLog.exe';
  Result[6] := 'dmSlaveDeviceNextViewer.exe';
end;

{ Query WMI for a running image name. Returns False on any COM failure so a
  locked-down machine degrades to "assume not running" rather than blocking. }
function IsProcessRunning(const ExeName: String): Boolean;
var
  Locator, Svc, Items: Variant;
begin
  Result := False;
  try
    Locator := CreateOleObject('WbemScripting.SWbemLocator');
    Svc := Locator.ConnectServer('.', 'root\CIMV2');
    Items := Svc.ExecQuery(
      'SELECT Name FROM Win32_Process WHERE Name = "' + ExeName + '"');
    Result := Items.Count > 0;
  except
    Log('WMI query failed for ' + ExeName + ' - assuming not running');
  end;
end;

{ Build a newline-separated list of whichever guarded processes are up. }
function RunningProcessList: String;
var
  Names: TArrayOfString;
  I: Integer;
begin
  Result := '';
  Names := GuardedProcesses;
  for I := 0 to GetArrayLength(Names) - 1 do
  begin
    if IsProcessRunning(Names[I]) then
      Result := Result + '    ' + Names[I] + #13#10;
  end;
end;

procedure KillGuardedProcesses;
var
  Names: TArrayOfString;
  I, Code: Integer;
begin
  Names := GuardedProcesses;
  for I := 0 to GetArrayLength(Names) - 1 do
  begin
    if IsProcessRunning(Names[I]) then
    begin
      { /T also kills children — a server that spawned helpers }
      Exec(ExpandConstant('{sys}\taskkill.exe'),
           '/F /T /IM "' + Names[I] + '"',
           '', SW_HIDE, ewWaitUntilTerminated, Code);
      Log('taskkill ' + Names[I] + ' -> ' + IntToStr(Code));
    end;
  end;
  { give the OS a moment to release file handles }
  Sleep(1500);
end;

{ Shared prompt. Returns True if it is safe to proceed. }
function EnsureProcessesClosed(const ActionText: String): Boolean;
var
  RunList: String;
begin
  Result := True;
  RunList := RunningProcessList;
  if RunList = '' then
    Exit;

  if MsgBox('以下程序正在运行，' + ActionText + '前必须关闭：' + #13#10 + #13#10 +
            RunList + #13#10 +
            '点击"是"强制关闭这些程序并继续。' + #13#10 +
            '点击"否"取消，手动关闭后重试。',
            mbConfirmation, MB_YESNO) = IDYES then
  begin
    KillGuardedProcesses;
    RunList := RunningProcessList;
    if RunList <> '' then
    begin
      MsgBox('以下程序无法关闭：' + #13#10 + #13#10 + RunList + #13#10 +
             '请手动结束后重试。', mbError, MB_OK);
      Result := False;
    end;
  end
  else
    Result := False;
end;

{ ===========================================================================
  PART 2 — settings.ini generation

  Written to match Qt QSettings expectations:
    - UTF-8, no BOM, CRLF   -> SaveStringsToUTF8FileWithoutBOM
    - forward slashes only  -> backslash is a QSettings ESCAPE char.
      Backslashes are what produced "d:rogram FilesmServer" previously:
      \P \D \S were swallowed on read-back.

  The file is regenerated unconditionally on every install. The shipped
  profile is authoritative; on-site edits are not preserved.
  =========================================================================== }

var
  Buf: TArrayOfString;
  BufCount: Integer;

function MainDirFwd: String;
begin
  Result := ExpandConstant('{app}');
  StringChangeEx(Result, '\', '/', True);
  while (Length(Result) > 0) and (Result[Length(Result)] = '/') do
    Result := Copy(Result, 1, Length(Result) - 1);
end;

procedure BufReset;
begin
  BufCount := 0;
  SetArrayLength(Buf, 64);
end;

procedure Add(const S: String);
begin
  if BufCount >= GetArrayLength(Buf) then
    SetArrayLength(Buf, GetArrayLength(Buf) * 2);
  Buf[BufCount] := S;
  BufCount := BufCount + 1;
end;

{ Emit one ServerInfos block. Pass '' for fields that must stay empty. }
procedure AddServer(Index: Integer; const AName, ASrvApp, ASrvArgs,
  AViewApp, AViewArgs, ADepends: String);
var
  P: String;
begin
  P := '1\ServerInfos\' + IntToStr(Index) + '\';
  Add(P + 'serverName=' + AName);
  Add(P + 'serverApp=' + ASrvApp);
  Add(P + 'serverAppArguments=' + ASrvArgs);
  Add(P + 'viewerApp=' + AViewApp);
  Add(P + 'viewerAppArguments=' + AViewArgs);
  Add(P + 'dependsOnServerName=' + ADepends);
end;

procedure GenerateSettingsIni;
var
  IniPath, D: String;
begin
  IniPath := ExpandConstant('{app}\settings.ini');
  D := MainDirFwd;
  BufReset;

  Add('[system]');
  Add('autoStart=true');
  Add('hideMainWindowWhenStart=true');
  Add('autoShowWindow=true');
  Add('floatingSize=32');
  Add('cardColumns=2');
  Add('maxOutputLines=200');
  Add('');

  Add('[Profiles]');
  Add('1\name=Default');

  AddServer(1, '物理',
    D + '/{#ExePhysics}',
    '"-window=0"', '', '', '');

  AddServer(2, '导航',
    D + '/{#ExeNavSrv}',
    '-fCONFIG-OMMO-MagPETD',
    D + '/{#ExeNavView}',
    '', 'ommo');

  AddServer(3, 'ommo',
    D + '/{#ExeOmmo}',
    '', '', '', '');

  AddServer(4, '下位机',
    D + '/{#ExeSlaveSrv}',
    '',
    D + '/{#ExeSlaveView}',
    '', '');

  Add('1\ServerInfos\size=4');
  Add('size=1');
  Add('');

  Add('[ActiveProfile]');
  Add('name=Default');
  Add('');

  Add('[Path]');
  Add('MainDir=' + D);
  Add('SlaveDir=' + D + '/{#DirSlave}');
  Add('OmmoSdkDir=' + D + '/{#DirOmmo}');

  SetArrayLength(Buf, BufCount);

  if SaveStringsToUTF8FileWithoutBOM(IniPath, Buf, False) then
    Log('settings.ini generated, MainDir=' + D)
  else
    Log('settings.ini GENERATE FAILED: ' + IniPath);
end;

{ ===========================================================================
  PART 3 — post-install verification

  Every path written above is checked on disk. A missing exe means one of the
  Exe* defines no longer matches what the archive unpacks into.
  =========================================================================== }

{ ===========================================================================
  PART 3 — post-install verification

  Every path written into settings.ini is checked on disk. A missing exe
  means one of the Exe* defines no longer matches what the archive unpacks
  into.

  Root/Missing are globals because Inno's Pascal Script has no nested
  procedures.
  =========================================================================== }

var
  VerifyRoot: String;
  VerifyMissing: String;

procedure Probe(const Rel: String);
var
  Full: String;
begin
  Full := VerifyRoot + '\' + Rel;
  StringChangeEx(Full, '/', '\', True);
  if not FileExists(Full) then
  begin
    VerifyMissing := VerifyMissing + '    ' + Rel + #13#10;
    Log('WARNING: missing ' + Full);
  end;
end;

procedure VerifyInstall;
begin
  VerifyRoot := ExpandConstant('{app}');
  VerifyMissing := '';

  Probe('dmServerHub.exe');
  Probe('{#ExePhysics}');
  Probe('{#ExeNavSrv}');
  Probe('{#ExeNavView}');
  Probe('{#ExeOmmo}');
  Probe('{#ExeSlaveSrv}');
  Probe('{#ExeSlaveView}');

  if VerifyMissing <> '' then
    MsgBox('安装完成，但以下文件未找到：' + #13#10 + #13#10 + VerifyMissing + #13#10 +
           '相关服务可能无法启动，请联系开发人员。',
           mbError, MB_OK);
end;

{ ===========================================================================
  PART 4 — event handlers
  =========================================================================== }

function GetPrevInstall(var Path: String; var Ver: String): Boolean;
begin
  Path := '';
  Ver := '';
  Result := RegQueryStringValue(HKLM, 'SOFTWARE\DmServer', 'InstallPath', Path);
  if Result then
    RegQueryStringValue(HKLM, 'SOFTWARE\DmServer', 'Version', Ver);
end;

function InitializeSetup: Boolean;
var
  Path, Ver: String;
begin
  Result := EnsureProcessesClosed('安装');
  if not Result then
    Exit;

  if GetPrevInstall(Path, Ver) and DirExists(Path) then
  begin
    Result := MsgBox(
      '检测到已安装版本 ' + Ver + '：' + #13#10 +
      '    ' + Path + #13#10 + #13#10 +
      '继续将覆盖安装：目录下的服务程序会被清空重装，' + #13#10 +
      'settings.ini 将被重新生成（现有配置不保留）。' + #13#10 + #13#10 +
      '是否继续？',
      mbConfirmation, MB_YESNO) = IDYES;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep <> ssPostInstall then
    Exit;
  GenerateSettingsIni;
  VerifyInstall;
end;

function InitializeUninstall: Boolean;
begin
  Result := EnsureProcessesClosed('卸载');
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  { second sweep: something may have been launched between the prompt and now }
  if CurUninstallStep = usUninstall then
    KillGuardedProcesses;
end;