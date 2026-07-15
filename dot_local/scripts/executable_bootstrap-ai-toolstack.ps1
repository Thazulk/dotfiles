# Install the portable AI development toolstack on native Windows.
# Run explicitly after chezmoi apply; applying dotfiles must not install packages.
$ErrorActionPreference = 'Continue'
$env:Path = "$HOME/.local/bin;$env:Path"

function Test-ToolCommand {
    param([Parameter(Mandatory = $true)][string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-ToolStep {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][scriptblock]$Action
    )
    Write-Host "+ $Label"
    try {
        & $Action
    } catch {
        Write-Warning "$Label failed: $($_.Exception.Message)"
    }
}

function Test-CodexMcp {
    param([Parameter(Mandatory = $true)][string]$Name)
    return ((& codex mcp list 2>$null) -match "^$([regex]::Escape($Name))\s")
}

function Add-CodexMcp {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Command,
        [string[]]$Arguments = @()
    )
    if (Test-CodexMcp $Name) {
        Write-Host "ok: Codex MCP $Name"
    } else {
        Invoke-ToolStep "codex mcp add $Name" { & codex mcp add $Name -- $Command @Arguments }
    }
}

Write-Host '==> AI toolstack bootstrap'

if (Test-ToolCommand mise) {
    Invoke-ToolStep 'mise install' { mise install }
} else {
    Write-Warning 'mise is missing; install it first, then rerun this script.'
}

if (-not (Test-ToolCommand rtk)) {
    if (Test-ToolCommand brew) {
        Invoke-ToolStep 'brew install rtk' { brew install rtk }
    } else {
        Write-Warning 'RTK needs a package-manager install on this platform.'
    }
}

if (Test-ToolCommand npm) {
    Invoke-ToolStep 'npm MCP tools' {
        npm install -g --allow-scripts=@suatkocar/codegraph,codebase-memory-mcp @upstash/context7-mcp codebase-memory-mcp @suatkocar/codegraph
    }
} else {
    Write-Warning 'npm is missing.'
}

if (Test-ToolCommand uv) {
    if (-not (Test-ToolCommand ddgs)) { Invoke-ToolStep 'uv tool install ddgs' { uv tool install ddgs } }
    if (-not (Test-ToolCommand headroom)) { Invoke-ToolStep 'uv tool install headroom-ai[all]' { uv tool install 'headroom-ai[all]' } }
    if (-not (Test-ToolCommand repowise)) { Invoke-ToolStep 'uv tool install repowise' { uv tool install repowise } }
} else {
    Write-Warning 'uv is missing; DDGS, Headroom, and Repowise were skipped.'
}

if (Test-ToolCommand codex) {
    foreach ($server in @(
        @{ Name = 'context7'; Command = 'context7-mcp'; Arguments = @() },
        @{ Name = 'codebase-memory'; Command = 'codebase-memory-mcp'; Arguments = @() },
        @{ Name = 'codegraph'; Command = 'codegraph'; Arguments = @('serve') },
        @{ Name = 'ddgs'; Command = 'ddgs'; Arguments = @('mcp') },
        @{ Name = 'repowise'; Command = 'repowise'; Arguments = @('mcp') }
    )) {
        $resolved = Get-Command $server.Command -ErrorAction SilentlyContinue
        if ($null -ne $resolved) {
            Add-CodexMcp $server.Name $resolved.Source $server.Arguments
        }
    }
} else {
    Write-Warning 'Codex is missing; MCP configuration was skipped.'
}

if ($env:TOOLSTACK_ENABLE_RTK -eq '1' -and (Test-ToolCommand rtk)) {
    Invoke-ToolStep 'rtk init --global --codex' { rtk init --global --codex }
} else {
    Write-Host 'optional: $env:TOOLSTACK_ENABLE_RTK = "1"; .\bootstrap-ai-toolstack.ps1'
}

if ($env:TOOLSTACK_ENABLE_HEADROOM -eq '1' -and (Test-ToolCommand headroom)) {
    Invoke-ToolStep 'headroom install apply' { headroom install apply }
} else {
    Write-Host 'optional: $env:TOOLSTACK_ENABLE_HEADROOM = "1"; .\bootstrap-ai-toolstack.ps1'
}

Write-Host '==> Done. Run the Unix check script from WSL/Git Bash, or inspect: codex mcp list.'
