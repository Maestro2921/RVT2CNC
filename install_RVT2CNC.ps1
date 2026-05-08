$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogoPath = Join-Path $ScriptDir "RVT2CNC_logo.png"
$LocalZip = Join-Path $ScriptDir "RVT2CNC.extension.zip"

$PyRevitExtensionsDir = Join-Path $env:APPDATA "pyRevit\Extensions"
$InstallDir = Join-Path $PyRevitExtensionsDir "RVT2CNC.extension"
$TempRoot = Join-Path $env:TEMP ("RVT2CNC_install_" + [guid]::NewGuid().ToString())
$ExtractDir = Join-Path $TempRoot "extract"

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="RVT2CNC Installer"
        Width="640"
        Height="380"
        WindowStartupLocation="CenterScreen"
        ResizeMode="NoResize"
        Background="#1E1E1E">
    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="185"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <Border Grid.Row="0" Background="#111111" BorderBrush="#333333" BorderThickness="1" CornerRadius="8" Padding="12" Margin="0,0,0,14">
            <Image Name="LogoImage" Stretch="Uniform"/>
        </Border>
        <TextBlock Grid.Row="1" Text="RVT2CNC pyRevit Installer" Foreground="White" FontSize="22" FontWeight="Bold" HorizontalAlignment="Center" Margin="0,0,0,8"/>
        <TextBlock Grid.Row="2" Name="StatusText" Text="Voorbereiden..." Foreground="White" FontSize="13" TextWrapping="Wrap" HorizontalAlignment="Center" Margin="0,0,0,12"/>
        <ProgressBar Grid.Row="3" Name="ProgressBar" Height="18" Minimum="0" Maximum="100" Value="0" Margin="0,0,0,18"/>
        <Button Grid.Row="4" Name="CloseButton" Content="Sluiten" Width="110" Height="32" HorizontalAlignment="Center" IsEnabled="False"/>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$Window = [Windows.Markup.XamlReader]::Load($reader)
$LogoImage = $Window.FindName("LogoImage")
$StatusText = $Window.FindName("StatusText")
$ProgressBar = $Window.FindName("ProgressBar")
$CloseButton = $Window.FindName("CloseButton")

if (Test-Path $LogoPath) {
    $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
    $bitmap.BeginInit()
    $bitmap.UriSource = New-Object System.Uri($LogoPath, [System.UriKind]::Absolute)
    $bitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
    $bitmap.EndInit()
    $LogoImage.Source = $bitmap
}

$CloseButton.Add_Click({ $Window.Close() })

function Update-UI {
    param([string]$Text, [int]$Progress)
    $StatusText.Text = $Text
    $ProgressBar.Value = $Progress
    $Window.Dispatcher.Invoke([Action]{}, [Windows.Threading.DispatcherPriority]::Background)
}

function Install-RVT2CNC {
    try {
        Update-UI "pyRevit Extensions-map controleren..." 5
        if (!(Test-Path $PyRevitExtensionsDir)) {
            New-Item -ItemType Directory -Path $PyRevitExtensionsDir -Force | Out-Null
        }

        if (!(Test-Path $TempRoot)) {
            New-Item -ItemType Directory -Path $TempRoot -Force | Out-Null
        }

        if (!(Test-Path $LocalZip)) {
            throw "RVT2CNC.extension.zip zit niet in de installer."
        }

        Update-UI "Plugin uitpakken..." 35
        if (Test-Path $ExtractDir) { Remove-Item $ExtractDir -Recurse -Force }
        New-Item -ItemType Directory -Path $ExtractDir -Force | Out-Null
        Expand-Archive -Path $LocalZip -DestinationPath $ExtractDir -Force

        Update-UI "Pluginmap zoeken..." 55
        $ExtractedPluginDir = Get-ChildItem -Path $ExtractDir -Recurse -Directory |
            Where-Object { $_.Name -ieq "RVT2CNC.extension" } |
            Select-Object -First 1

        if (!$ExtractedPluginDir) {
            throw "Kon geen RVT2CNC.extension map vinden in de zip."
        }

        Update-UI "Oude installatie verwijderen..." 70
        if (Test-Path $InstallDir) { Remove-Item $InstallDir -Recurse -Force }

        Update-UI "RVT2CNC installeren..." 85
        Copy-Item $ExtractedPluginDir.FullName $InstallDir -Recurse -Force

        Update-UI "Klaar. Open Revit en klik op pyRevit Reload." 100
        $CloseButton.IsEnabled = $true
    }
    catch {
        Update-UI ("Installatie mislukt: " + $_.Exception.Message) 0
        $CloseButton.IsEnabled = $true
    }
    finally {
        try {
            if (Test-Path $TempRoot) { Remove-Item $TempRoot -Recurse -Force }
        }
        catch {}
    }
}

$Window.Add_ContentRendered({ Install-RVT2CNC })
$Window.ShowDialog() | Out-Null
