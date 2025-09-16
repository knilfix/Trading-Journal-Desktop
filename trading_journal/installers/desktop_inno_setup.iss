; -- TradingJournal.iss --
; Inno Setup script for Trading Journal application

#define MyAppName "Trading Journal"
#define MyAppVersion "1.5"
#define MyAppPublisher "Monster University, Inc."
#define MyAppURL "https://www.example.com/"
#define MyAppExeName "trading_journal.exe"
#define MyAppIcon "favicon.ico"  ; Your application icon

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
OutputDir=E:\Programming Projects\Flutter Projects\Trading Journal\Trading-Journal-Desktop\trading_journal\installers
OutputBaseFilename=trading_journal_v1.5
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Main application files
Source: "E:\Programming Projects\Flutter Projects\Trading Journal\Trading-Journal-Desktop\trading_journal\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Programming Projects\Flutter Projects\Trading Journal\Trading-Journal-Desktop\trading_journal\build\windows\x64\runner\Release\awesome_notifications_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Programming Projects\Flutter Projects\Trading Journal\Trading-Journal-Desktop\trading_journal\build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Programming Projects\Flutter Projects\Trading Journal\Trading-Journal-Desktop\trading_journal\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Programming Projects\Flutter Projects\Trading Journal\Trading-Journal-Desktop\trading_journal\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; Application icon file
Source: "E:\Programming Projects\Flutter Projects\Trading Journal\Trading-Journal-Desktop\trading_journal\installers\favicon.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
; Start Menu shortcut (uses the embedded EXE icon)
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
  
; Desktop shortcut (uses the embedded EXE icon)
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent