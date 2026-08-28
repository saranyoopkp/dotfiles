param(
    [Parameter(Mandatory = $true)]
    [string]$WslHome
)

$ErrorActionPreference = 'Stop'
$targetRoot = Join-Path $WslHome '.config\opencode'
$source = Join-Path $PSScriptRoot 'tools\memory-tools.js'
$targetDir = Join-Path $targetRoot 'tools'
$target = Join-Path $targetDir 'memory.js'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
if (Test-Path -LiteralPath $target) {
    $backup = "$target.bak-pre-memory-tools"
    $index = 1
    while (Test-Path -LiteralPath $backup) { $backup = "$target.bak-pre-memory-tools-$index"; $index++ }
    Move-Item -LiteralPath $target -Destination $backup
    Write-Host "backup: $backup"
}
[System.IO.File]::WriteAllText($target, (Get-Content -LiteralPath $source -Raw), $utf8NoBom)
Write-Host "OpenCode-native memory tools installed: $target"
Write-Host 'No Claude plugin, hook, or settings file was installed.'
