param(
    [Parameter(Mandatory = $true)]
    [string]$WslHome
)

& (Join-Path $PSScriptRoot 'install-full.ps1') -WslHome $WslHome
