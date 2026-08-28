param(
    [Parameter(Mandatory = $true)]
    [string]$WslHome
)

$ErrorActionPreference = 'Stop'

$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$sourceRoot = Join-Path $repo 'claude'
$targetRoot = Join-Path $WslHome '.config\opencode'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Get-BackupPath {
    param([string]$Path)
    $candidate = "$Path.bak-pre-dotfiles-full"
    $index = 1
    while (Test-Path -LiteralPath $candidate) {
        $candidate = "$Path.bak-pre-dotfiles-full-$index"
        $index++
    }
    return $candidate
}

function Write-ManagedFile {
    param([string]$Path, [string]$Content)
    if (Test-Path -LiteralPath $Path) {
        $existing = [System.IO.File]::ReadAllText($Path)
        if ($existing -eq $Content) { return }
        $backup = Get-BackupPath $Path
        Move-Item -LiteralPath $Path -Destination $backup
        Write-Host "backup: $backup"
    }
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Get-SkillId {
    param([System.IO.DirectoryInfo]$Directory)
    $relative = [System.IO.Path]::GetRelativePath((Join-Path $sourceRoot 'skills'), $Directory.FullName)
    $parts = $relative -split '[\\/]'
    if ($parts.Count -eq 1) { return $parts[0] }
    return "$($parts[0])-$($parts[1])"
}

New-Item -ItemType Directory -Force -Path $targetRoot, (Join-Path $targetRoot 'agents'), (Join-Path $targetRoot 'commands'), (Join-Path $targetRoot 'skills') | Out-Null

# Rules: OpenCode has one global AGENTS.md, so aggregate the current Claude rules.
$ruleFiles = Get-ChildItem -LiteralPath (Join-Path $sourceRoot 'rules') -Recurse -File -Filter '*.md' | Sort-Object FullName
$agentRules = @(
    '# Dotfiles shared rules (OpenCode full adapter)',
    '',
    'Generated from claude/rules by opencode/install-full.ps1.',
    'The Claude Code installation remains separate.',
    ''
)
foreach ($rule in $ruleFiles) {
    $agentRules += "## $($rule.BaseName)"
    $agentRules += ''
    $agentRules += (Get-Content -LiteralPath $rule.FullName -Raw).TrimEnd()
    $agentRules += ''
}
Write-ManagedFile (Join-Path $targetRoot 'AGENTS.md') (($agentRules -join "`n") + "`n")

# Agents: convert Claude tool names/frontmatter to OpenCode modes and permissions.
$agentSpecs = @(
    @{ Source = 'SCC-v1.0.1.md'; Target = 'scc.md'; Mode = 'primary' },
    @{ Source = 'scout.md'; Target = 'scout.md'; Mode = 'subagent' },
    @{ Source = 'ACV-v1.0.1.md'; Target = 'acv.md'; Mode = 'subagent' }
)
foreach ($spec in $agentSpecs) {
    $sourcePath = Join-Path (Join-Path $sourceRoot 'agents') $spec.Source
    $source = Get-Content -LiteralPath $sourcePath -Raw
    $description = ([regex]::Match($source, '(?m)^description:\s*(.+)$')).Groups[1].Value.Trim()
    $body = [regex]::Replace($source, '(?s)^---\s*\r?\n.*?\r?\n---\s*\r?\n', '')
    $lines = @('---', "description: $description", "mode: $($spec.Mode)")
    if ($spec.Mode -eq 'subagent') {
        $lines += 'permission:'
        $lines += '  edit: deny'
        $lines += '  task: deny'
        $lines += '  bash: allow'
    }
    $lines += '---'
    $lines += ''
    $lines += $body.TrimStart()
    Write-ManagedFile (Join-Path (Join-Path $targetRoot 'agents') $spec.Target) (($lines -join "`n") + "`n")
}

# Skills: create an OpenCode-compatible projection while leaving Claude ids untouched.
$skillSourceRoot = Join-Path $sourceRoot 'skills'
$skillTargetRoot = Join-Path $targetRoot 'skills'
$skillFiles = Get-ChildItem -LiteralPath $skillSourceRoot -Recurse -File -Filter 'SKILL.md' | Sort-Object FullName
$prefixes = @('api-design', 'data-design', 'docs', 'ops', 'research', 'ui-ux-baseline')
foreach ($skill in $skillFiles) {
    $skillId = Get-SkillId $skill.Directory
    $content = Get-Content -LiteralPath $skill.FullName -Raw
    $content = [regex]::Replace($content, '(?m)^name:\s*.*$', "name: $skillId", 1)
    foreach ($prefix in $prefixes) { $content = $content.Replace("$prefix`:", "$prefix-") }
    $skillTargetDir = Join-Path $skillTargetRoot $skillId
    New-Item -ItemType Directory -Force -Path $skillTargetDir | Out-Null
    Write-ManagedFile (Join-Path $skillTargetDir 'SKILL.md') $content

    # Add a hyphenated command alias for each skill for TUI users.
    $command = @(
        '---',
        "description: Load and follow the $skillId skill for this task",
        'agent: scc',
        '---',
        '',
        "Load the OpenCode skill `$skillId` with the native skill tool, then follow it for the user's task. Preserve the user's objective and scope."
    ) -join "`n"
    Write-ManagedFile (Join-Path (Join-Path $targetRoot 'commands') "$skillId.md") ($command + "`n")
}

Write-Host ''
Write-Host "OpenCode full adapter installed under: $targetRoot"
Write-Host 'Existing ~/.claude files and ~/.config/opencode/opencode.jsonc were not changed.'
Write-Host "Rules: $($ruleFiles.Count) | Agents: $($agentSpecs.Count) | Skills/commands: $($skillFiles.Count) | Plugins: not installed"
