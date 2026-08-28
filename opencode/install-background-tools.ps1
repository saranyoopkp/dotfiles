param(
    [Parameter(Mandatory = $true)]
    [string]$WslHome
)

$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot 'tools\background-tools.js'
$targetDir = Join-Path (Join-Path $WslHome '.config\opencode') 'tools'
$target = Join-Path $targetDir 'background.js'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
if (Test-Path -LiteralPath $target) {
    $backup = "$target.bak-pre-background-tools"
    $index = 1
    while (Test-Path -LiteralPath $backup) { $backup = "$target.bak-pre-background-tools-$index"; $index++ }
    Move-Item -LiteralPath $target -Destination $backup
    Write-Host "backup: $backup"
}
[System.IO.File]::WriteAllText($target, (Get-Content -LiteralPath $source -Raw), $utf8NoBom)
Write-Host "OpenCode-native background tools installed: $target"
Write-Host 'No Claude plugin, hook, or settings file was installed.'
