; -- TradingJournal.iss --
; Inno Setup script for Trading Journal application

; ==================== CENTRALIZED VERSION CONFIGURATION ====================
#define AppVersion "1.7"  ; ← CHANGE ONLY THIS FOR NEW VERSIONS
; ==========================================================================

#define MyAppName "Trading Journal"
#define MyAppVersion AppVersion
#define MyAppPublisher "Monster University, Inc."
#define MyAppURL "https://www.example.com/"
#define MyAppExeName "trading_journal.exe"
#define MyAppIcon "favicon.ico"
#define BuildPath "E:\Programming Projects\Flutter Projects\Trading-Journal-Desktop\trading_journal\build\windows\x64\runner\Release"
#define InstallersPath "E:\Programming Projects\Flutter Projects\Trading-Journal-Desktop\trading_journal\installers"

[Setup]
AppId={{4116A86E-5709-4C40-9EBA-FF5D2BA3082B}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
DisableProgramGroupPage=yes
OutputDir={#InstallersPath}
OutputBaseFilename=trading_journal_v{#AppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
VersionInfoVersion={#AppVersion}
VersionInfoProductVersion={#AppVersion}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Main application files - SIMPLIFIED!
Source: "{#BuildPath}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildPath}\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildPath}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; Application icon file
Source: "{#InstallersPath}\{#MyAppIcon}"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
; Start Menu shortcut
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
  
; Desktop shortcut
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}\data"  ; 