# Downloads GodotSteam (the Steam addon) into addons/godotsteam. Run it once per PC from the repo folder:
#   powershell -ExecutionPolicy Bypass -File tools/godotsteam.ps1
# Then import: godot --headless --path . --import
# Steam has to be open before the game starts. Without the addon the game plays online by IP only.
$ErrorActionPreference = "Stop"
$version = "4.23.2"
$url = "https://codeberg.org/godotsteam/godotsteam/releases/download/v$version-gde/godotsteam-$version-gdextension-plugin-4.4.zip"
$root = Split-Path -Parent $PSScriptRoot
$zip = Join-Path $env:TEMP "godotsteam-$version.zip"
$unzipped = Join-Path $env:TEMP "godotsteam-$version"
Write-Host "Downloading GodotSteam $version..."
Invoke-WebRequest -Uri $url -OutFile $zip
if (Test-Path $unzipped) { Remove-Item -Recurse -Force $unzipped }
Expand-Archive -Path $zip -DestinationPath $unzipped
$target = Join-Path $root "addons\godotsteam"
if (Test-Path $target) { Remove-Item -Recurse -Force $target }
Copy-Item -Recurse (Join-Path $unzipped "addons\godotsteam") $target
Write-Host "GodotSteam is in $target"
