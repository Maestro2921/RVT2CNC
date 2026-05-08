; RVT2CNC Inno Setup installer
#define MyAppName "RVT2CNC"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "RVT2CNC"

[Setup]
AppId={{B31A474A-F645-45E9-8F92-RVT2CNC0001}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={tmp}\RVT2CNC
DisableProgramGroupPage=yes
DisableDirPage=yes
OutputDir=Output
OutputBaseFilename=RVT2CNC_Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
Uninstallable=no
PrivilegesRequired=lowest

[Files]
Source: "install_RVT2CNC.ps1"; DestDir: "{tmp}\RVT2CNC"; Flags: ignoreversion
Source: "install_RVT2CNC.bat"; DestDir: "{tmp}\RVT2CNC"; Flags: ignoreversion
Source: "RVT2CNC_logo.png"; DestDir: "{tmp}\RVT2CNC"; Flags: ignoreversion
Source: "RVT2CNC.extension.zip"; DestDir: "{tmp}\RVT2CNC"; Flags: ignoreversion

[Run]
Filename: "{tmp}\RVT2CNC\install_RVT2CNC.bat"; Flags: waituntilterminated
