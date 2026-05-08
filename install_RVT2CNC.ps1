
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LocalZip = Join-Path $ScriptDir "RVT2CNC.extension.zip"

$PyRevitExtensionsDir = Join-Path $env:APPDATA "pyRevit\Extensions"
$InstallDir = Join-Path $PyRevitExtensionsDir "Revit2CNC.extension"

$temp = Join-Path $env:TEMP ("RVT2CNC_" + [guid]::NewGuid().ToString())
$extract = Join-Path $temp "extract"

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
Title="RVT2CNC Installer"
Width="640"
Height="340"
WindowStartupLocation="CenterScreen"
ResizeMode="NoResize"
Background="#1E1E1E">
<Grid Margin="20">
<Grid.RowDefinitions>
<RowDefinition Height="*"/>
<RowDefinition Height="Auto"/>
<RowDefinition Height="Auto"/>
</Grid.RowDefinitions>

<TextBlock Name="StatusText"
Grid.Row="0"
Foreground="White"
FontSize="26"
TextAlignment="Center"
VerticalAlignment="Center"
TextWrapping="Wrap"/>

<ProgressBar Name="Progress"
Grid.Row="1"
Height="18"
Margin="0,20,0,20"/>

<Button Name="CloseBtn"
Grid.Row="2"
Content="Sluiten"
Width="120"
Height="34"
HorizontalAlignment="Center"
IsEnabled="False"/>
</Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$Window = [Windows.Markup.XamlReader]::Load($reader)

$Status = $Window.FindName("StatusText")
$Progress = $Window.FindName("Progress")
$CloseBtn = $Window.FindName("CloseBtn")

$CloseBtn.Add_Click({ $Window.Close() })

function UpdateUI($text, $value) {
    $Status.Text = $text
    $Progress.Value = $value
    $Window.Dispatcher.Invoke([Action]{}, "Background")
}

function RunInstall {

try {

UpdateUI "Plugin voorbereiden..." 10

New-Item -ItemType Directory -Path $extract -Force | Out-Null

Expand-Archive -Path $LocalZip -DestinationPath $extract -Force

UpdateUI "Pluginmap zoeken..." 40

$pluginDir = Get-ChildItem -Path $extract -Recurse -Directory | Where-Object {
    $_.Name -ieq "Revit2CNC.extension" -or
    $_.Name -ieq "RVT2CNC.extension"
} | Select-Object -First 1

if (!$pluginDir) {
    throw "Geen extension-map gevonden in ZIP."
}

UpdateUI "Installeren in pyRevit..." 70

New-Item -ItemType Directory -Path $PyRevitExtensionsDir -Force | Out-Null

if (Test-Path $InstallDir) {
    Remove-Item $InstallDir -Recurse -Force
}

Copy-Item $pluginDir.FullName $InstallDir -Recurse -Force

UpdateUI "Installatie voltooid. Gebruik pyRevit Reload." 100

}
catch {
    UpdateUI ("FOUT: " + $_.Exception.Message) 0
}

$CloseBtn.IsEnabled = $true

}

$Window.Add_ContentRendered({ RunInstall })
$Window.ShowDialog() | Out-Null
