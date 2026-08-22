#define MyAppName "Chrome Helper"
#define MyAppVersion "1.1.0"
#define MyAppPublisher "Prashil Koirala"
#define MyAppExeName "ChromeHelper.exe"

[Setup]
AppId={{B52AA9D4-1F1F-4E0A-98EB-CE61497FB6CB}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL=https://prashilkoirala.com.np/
AppSupportURL=https://github.com/prashilthegreat/chrome-helper/issues
AppUpdatesURL=https://github.com/prashilthegreat/chrome-helper/releases/latest
DefaultDirName={autopf}\Chrome Helper
DefaultGroupName=Chrome Helper
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=installer-output
OutputBaseFilename=ChromeHelperSetup
SetupIconFile=ChromeHelper\Assets\pk-logo.ico
PrivilegesRequired=lowest
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription=Chrome profile launcher for Microsoft 365 Admin
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}
VersionInfoCopyright=Copyright (C) 2026 Prashil Koirala
VersionInfoOriginalFileName=ChromeHelperSetup.exe

[Files]
Source: "..\publish\ChromeHelper.exe"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\Chrome Helper"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\Chrome Helper"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: unchecked

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch Chrome Helper"; Flags: nowait postinstall skipifsilent
