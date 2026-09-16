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

function Add-CodexMcpIfMissing {
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

function Test-CodexPlugin {
    param([Parameter(Mandatory = $true)][string]$Name)
    return ((& codex plugin list 2>$null) -match "$([regex]::Escape($Name))\s.*installed")
}

function Test-ClaudePlugin {
    param([Parameter(Mandatory = $true)][string]$Name)
    return ((& claude plugin list 2>$null) -match [regex]::Escape($Name))
}

function Install-AgentPlugins {
    if ((Test-ToolCommand codex) -and -not (Test-CodexPlugin 'superpowers@openai-curated')) {
        Invoke-ToolStep 'codex plugin add superpowers@openai-curated' { & codex plugin add superpowers@openai-curated }
    }
    if ((Test-ToolCommand claude) -and -not (Test-ClaudePlugin 'superpowers@claude-plugins-official')) {
        Invoke-ToolStep 'claude plugin install superpowers@claude-plugins-official' { & claude plugin install superpowers@claude-plugins-official -y --scope user }
    }
}

Write-Host '==> AI toolstack bootstrap'

if (Test-ToolCommand mise) {
    Invoke-ToolStep 'mise install' { mise install }
} else {
    Write-Warning 'mise is missing; install it first, then rerun this script.'
}

if (Test-ToolCommand codex) {
    python "$PSScriptRoot/configure-agent-defaults"
}
Install-AgentPlugins

if (Test-ToolCommand nx-mcp) {
    $nxMcpPath = & mise which nx-mcp --tool npm:nx-mcp 2>$null
    $nxArgs = if ($env:TOOLSTACK_NX_WORKSPACE) { @($env:TOOLSTACK_NX_WORKSPACE) } else { @() }
    if (Test-ToolCommand codex) {
        if ($env:TOOLSTACK_NX_WORKSPACE) {
            Add-CodexMcp 'nx-mcp' $nxMcpPath $nxArgs
        } else {
            Add-CodexMcpIfMissing 'nx-mcp' $nxMcpPath $nxArgs
        }
    }
    if (Test-ToolCommand claude) {
        $userConfig = Join-Path $HOME '.claude.json'
        $existing = $null
        if (Test-Path $userConfig) {
            $existing = (Get-Content $userConfig -Raw | ConvertFrom-Json).mcpServers.'nx-mcp'
        }
        if ($null -eq $existing) {
            & claude mcp add --scope user nx-mcp -- $nxMcpPath @nxArgs
        } elseif ($env:TOOLSTACK_NX_WORKSPACE -and $existing.command -ne $nxMcpPath) {
            Write-Warning 'Claude MCP nx-mcp has a different path; remove it with --scope user and rerun.'
        } else {
            Write-Host 'ok: Claude MCP nx-mcp'
        }
    }
}

if ((Test-ToolCommand codex) -or (Test-ToolCommand claude)) {
    foreach ($server in @(
        @{ Name = 'context7'; Command = 'context7-mcp'; Tool = 'npm:@upstash/context7-mcp'; Arguments = @() },
        @{ Name = 'codebase-memory'; Command = 'codebase-memory-mcp'; Tool = 'npm:codebase-memory-mcp'; Arguments = @() },
        @{ Name = 'playwright'; Command = 'playwright-mcp'; Tool = 'npm:@playwright/mcp'; Arguments = @() },
        @{ Name = 'codegraph'; Command = 'codegraph'; Tool = 'npm:@suatkocar/codegraph'; Arguments = @('serve') },
        @{ Name = 'ddgs'; Command = 'ddgs'; Tool = 'pipx:ddgs'; Arguments = @('mcp') },
        @{ Name = 'repowise'; Command = 'repowise'; Tool = 'pipx:repowise'; Arguments = @('mcp') }
    )) {
        $toolPath = & mise which $server.Command --tool $server.Tool 2>$null
        $resolved = if ($LASTEXITCODE -eq 0) { Get-Command $toolPath -ErrorAction SilentlyContinue } else { $null }
        if ($null -ne $resolved) {
            if (Test-ToolCommand codex) {
                Add-CodexMcp $server.Name $resolved.Source $server.Arguments
            }
            if (Test-ToolCommand claude) {
                $userConfig = Join-Path $HOME '.claude.json'
                $existing = $null
                if (Test-Path $userConfig) {
                    $existing = (Get-Content $userConfig -Raw | ConvertFrom-Json).mcpServers.($server.Name)
                }
                if ($null -eq $existing) {
                    & claude mcp add --scope user $server.Name -- $resolved.Source @($server.Arguments)
                } elseif ($existing.command -ne $resolved.Source) {
                    Write-Warning "Claude MCP $($server.Name) has a different path; remove it with --scope user and rerun."
                }
            }
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
