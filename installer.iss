; Inno Setup Script for Printing Rates
; This script creates a Windows installer for Printing Rates
; Values are passed via command line defines from update_installer.ps1

#ifndef MyAppName
#define MyAppName "Printing Rates"
#endif

#ifndef MyAppVersion
#define MyAppVersion "0.0.7"
#endif

#ifndef MyPackageId
#define MyPackageId "printing-rates"
#endif

#ifndef MyAppDescription
#define MyAppDescription "Professional printing rate calculator and quotation tool"
#endif
#ifndef MyAppExecutable
#define MyAppExecutable "PrintingRates"
#endif

#define MyAppPublisher "Deadbush225"
#define MyAppURL "https://github.com/Deadbush225/" + MyPackageId
#define MyAppExeName MyAppExecutable + ".exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
AppId={{B8F2B8F2-1234-5678-9ABC-DEF0123456789}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableDirPage=no
UninstallDisplayIcon={app}\{#MyAppExeName}
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
DisableProgramGroupPage=yes
PrivilegesRequired=admin
OutputDir=windows-installer
OutputBaseFilename={#MyPackageId}Setup-{#MyAppVersion}-x64
SolidCompression=yes
Compression=lzma
WizardStyle=modern
SetupIconFile=src\icons\Printing Rates.ico

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1

[Files]
; Application files
Source: "install\bin\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "install\bin\eUpdater.exe"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "install\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Registry]
Root: HKCR; Subkey: ".prc"; ValueType: string; ValueName: ""; ValueData: "PrintingRatesProject"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "PrintingRatesProject"; ValueType: string; ValueName: ""; ValueData: "Printing Rates Project"; Flags: uninsdeletekey
Root: HKCR; Subkey: "PrintingRatesProject\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"
Root: HKCR; Subkey: "PrintingRatesProject\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; IconFilename: "{app}\icons\Printing Rates.ico"; Comment: "{#MyAppDescription}"
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; IconFilename: "{app}\icons\Printing Rates.ico"; Comment: "{#MyAppDescription}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; IconFilename: "{app}\icons\Printing Rates.ico"; Comment: "{#MyAppDescription}"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}\logs"
Type: filesandordirs; Name: "{app}\config"

[Code]
// Custom functions and procedures can be added here

function InitializeSetup(): Boolean;
begin
  // Check if running on a supported Windows version
  if not IsWin64 then begin
    MsgBox('This application requires a 64-bit version of Windows.', mbError, MB_OK);
    Result := False;
  end else
    Result := True;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then begin
    // Any post-installation tasks can be added here
  end;
end;
