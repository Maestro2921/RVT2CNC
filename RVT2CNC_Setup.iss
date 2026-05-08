
[Setup]
AppName=RVT2CNC
AppVersion=1.0
DefaultDirName={tmp}\RVT2CNC
OutputDir=Output
OutputBaseFilename=RVT2CNC_Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
DisableDirPage=yes
DisableProgramGroupPage=yes
Uninstallable=no

[Files]
Source: "install_RVT2CNC.ps1"; DestDir: "{tmp}\RVT2CNC"
Source: "RVT2CNC.extension.zip"; DestDir: "{tmp}\RVT2CNC"

[Run]
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -STA -File ""{tmp}\RVT2CNC\install_RVT2CNC.ps1"""; Flags: waituntilterminated runhidden
