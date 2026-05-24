#Requires -Version 5.1

$StateDir = "$env:USERPROFILE\.opencode-setup"
$StateFile = "$StateDir\state.txt"
$null = New-Item -Path $StateDir -ItemType Directory -Force

$State = 0
if (Test-Path $StateFile) { $State = Get-Content $StateFile -Raw -ErrorAction SilentlyContinue | ForEach-Object { $_ -replace '\s', '' } }

if ($State -eq 10) {
    Write-Host "=== OpenCode + Python/uv/jq + Jot + Skills + Zed are already installed ==="
    Write-Host "Run: opencode --help to get started."
    Write-Host "Run: jot --help to see jot commands."
    Write-Host "Run: zed --help to see Zed commands."
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host "=== OpenCode + Python/uv/jq + Jot + Skills + Zed Windows Setup ==="
Write-Host ""
Write-Host "Repository: https://github.com/udit-001/vibe-research"
Write-Host ""

function Save-State($n) { $n | Out-File -FilePath $StateFile -Encoding ascii }

function Check-Installed($cmd) { return (Get-Command $cmd -ErrorAction SilentlyContinue) -ne $null }

function Exec-Native($cmd) {
    if ($LASTEXITCODE -ne 0) { exit 1 }
}

# Phase 0 — Windows Terminal (REQUIRED)
if (-not (Check-Installed wt)) {
    Write-Host "[0/10] Installing Windows Terminal via winget..."
    winget install --id Microsoft.WindowsTerminal -e
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED. Windows Terminal is required for this setup."
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-Host "Windows Terminal installed. Close this terminal and open Windows Terminal, then run this script again."
    Read-Host "Press Enter to exit"
    exit 0
} else {
    Write-Host "Windows Terminal already installed."
}
Write-Host ""

# Phase 1 — Git
if (-not (Check-Installed git)) {
    Write-Host "[1/10] Installing Git via winget..."
    winget install -e --id Git.Git
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED."
        Read-Host "Press Enter to exit"
        exit 1
    }
    Save-State 1
    Write-Host ""
    Write-Host "Done. Close this terminal and open a new one, then run this script again."
    Read-Host "Press Enter to exit"
    exit 0
}

# Setup .bashrc with opencode alias
$Bashrc = "$env:USERPROFILE\.bashrc"
if (-not (Test-Path $Bashrc)) { "# Git Bash configuration" | Out-File -FilePath $Bashrc -Encoding ascii }
$BashrcContent = Get-Content $Bashrc -Raw -ErrorAction SilentlyContinue
if ($BashrcContent -notmatch 'alias oc=') {
    "`nalias oc='opencode'" | Add-Content $Bashrc
    Write-Host "Added 'oc' alias to $Bashrc"
}

# Phase 2 — Node.js
if (-not (Check-Installed node)) {
    Write-Host "[2/10] Installing Node.js via winget..."
    winget install -e --id OpenJS.NodeJS.LTS
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED."
        Read-Host "Press Enter to exit"
        exit 1
    }
    Save-State 2
    Write-Host ""
    Write-Host "Done. Close this terminal and open a new one, then run this script again."
    Read-Host "Press Enter to exit"
    exit 0
}

# Phase 3 — Python + uv + jq
if (-not (Check-Installed python)) {
    Write-Host "[3/10] Installing Python 3.13..."
    winget install -e --id Python.Python.3.13
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED."
        Read-Host "Press Enter to exit"
        exit 1
    }
    Save-State 3
    Write-Host ""
    Write-Host "Done. Close this terminal and open a new one, then run this script again."
    Read-Host "Press Enter to exit"
    exit 0
}

if (-not (Check-Installed uv)) {
    winget install -e --id astral-sh.uv *>$null
    if (-not (Check-Installed uv)) {
        pip install uv *>$null
        if (-not (Check-Installed uv)) {
            Write-Host "WARNING: Could not install uv. Install later with: pip install uv"
        }
    }
}
if (-not (Check-Installed jq)) {
    winget install -e --id jqlang.jq *>$null
    if (-not (Check-Installed jq)) {
        Write-Host "WARNING: Could not install jq. Install later with: winget install jqlang.jq"
    }
}

# Phase 4 — OpenCode
if (-not (Check-Installed opencode)) {
    Write-Host "[4/10] Installing OpenCode..."
    npm install -g opencode-ai --no-fund --no-audit
    if (-not (Check-Installed opencode)) {
        Write-Host "FAILED."
        Read-Host "Press Enter to exit"
        exit 1
    }
} else {
    Write-Host "[4/10] OpenCode already installed. Skipping."
}
Save-State 4

# Phase 5 — OpenCode DCP plugin
Write-Host "[5/10] DCP plugin is configured in config/opencode.json (auto-installed on next opencode start). Skipping."
Save-State 5

Write-Host ""
Write-Host "=== OpenCode installed successfully! ==="
Write-Host "Run: opencode --help to get started."
Write-Host ""

# Dev/playground directory
$null = New-Item -Path "$env:USERPROFILE\Dev\playground" -ItemType Directory -Force
Write-Host "Created: $env:USERPROFILE\Dev\playground"
Write-Host ""

# Windows Terminal configuration
Write-Host "Configuring Windows Terminal..."
$WtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$TemplateUrl = "https://raw.githubusercontent.com/udit-001/vibe-research/master/tools/setup-opencode/wt-settings.json"

try {
    $json = (New-Object Net.WebClient).DownloadString($TemplateUrl)
    $template = $json | ConvertFrom-Json -Depth 100

    $profile = $template.profiles.list | Where-Object { $_.name -eq "Git Bash" }
    if ($profile) {
        $profile.startingDirectory = "$env:USERPROFILE\Dev\playground"
    }

    if (Test-Path $WtSettings) {
        $existing = Get-Content $WtSettings -Raw | ConvertFrom-Json -Depth 100
        $autoProfiles = $existing.profiles.list | Where-Object { $_.name -ne "Git Bash" }
        if ($autoProfiles) {
            $template.profiles.list += $autoProfiles
        }
        if ($existing.actions) {
            $template.actions = $existing.actions
        }
    }

    $template | ConvertTo-Json -Depth 100 | Set-Content $WtSettings
    Write-Host "Windows Terminal configured: Git Bash as default profile"
} catch {
    Write-Host "WARNING: Could not download Windows Terminal config template."
    Write-Host "You can manually configure Windows Terminal: set Git Bash as default profile."
}

# Phase 6 — PM2
if (-not (Check-Installed pm2)) {
    Write-Host "[6/10] Installing PM2..."
    npm install -g pm2
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED."
        Read-Host "Press Enter to exit"
        exit 1
    }
} else {
    Write-Host "[6/10] PM2 already installed. Skipping."
}
Save-State 6

# Phase 7 — Jot CLI
if (-not (Check-Installed jot)) {
    Write-Host "[7/10] Installing Jot CLI..."
    npm install -g @mariozechner/jot
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED."
        Read-Host "Press Enter to exit"
        exit 1
    }
} else {
    Write-Host "[7/10] Jot CLI already installed. Skipping."
}
Save-State 7

# Phase 8 — Jot Setup
Write-Host "[8/10] Setting up Jot..."
$JotDataDir = "$env:USERPROFILE\jot-data"
$null = New-Item -Path "$JotDataDir\logs" -ItemType Directory -Force

$Pm2Config = "$env:USERPROFILE\jot-pm2.json"
if (-not (Test-Path $Pm2Config)) {
    $pm2Json = @{
        apps = @(@{
            name         = "jot"
            script       = "jot"
            args         = @("serve", "--port=3210", "--data=$JotDataDir")
            instances    = 1
            exec_mode    = "fork"
            env          = @{ NODE_ENV = "production" }
            log_file     = "$JotDataDir\logs\combined.log"
            out_file     = "$JotDataDir\logs\out.log"
            error_file   = "$JotDataDir\logs\error.log"
            autorestart  = $true
            max_restarts = 10
            min_uptime   = "10s"
        })
    }
    $pm2Json | ConvertTo-Json -Depth 10 | Out-File -FilePath $Pm2Config -Encoding ascii
    Write-Host "Created PM2 config at $Pm2Config"
} else {
    Write-Host "PM2 config already exists at $Pm2Config"
}

if (-not (Check-Installed pm2)) {
    Write-Host "PM2 not found on PATH. Open a new terminal and run this script again."
    Read-Host "Press Enter to exit"
    exit 0
}
if (-not (Check-Installed jot)) {
    Write-Host "Jot CLI not found on PATH. Open a new terminal and run this script again."
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host "Starting Jot server..."
pm2 start $Pm2Config 2>$null
if ($LASTEXITCODE -ne 0) { pm2 restart jot }
if ($LASTEXITCODE -ne 0) {
    Write-Host "FAILED to start Jot server. After setup, run: pm2 start $Pm2Config"
} else {
    Write-Host "Waiting for Jot server to be ready..."
    Start-Sleep -Seconds 5

    if (Check-Installed curl -and (Check-Installed jq)) {
        $JotUrl = "http://localhost:3210"
        $JotPassword = "12345678"
        $ApiKeyLabel = "opencode-skill"

        Write-Host "Setting up Jot authentication..."
        $setupResp = curl -s -X POST "$JotUrl/api/auth/setup" -H "Content-Type: application/json" -d "{\"password\":\"$JotPassword\",\"confirmPassword\":\"$JotPassword\"}"
        $setupOk = $setupResp | ConvertFrom-Json -ErrorAction SilentlyContinue

        if ($setupOk -and $setupOk.token) {
            Write-Host "Owner account created. Exchanging device token..."
            $null = curl -s -c "$env:TEMP\jot-cookies.txt" -X POST "$JotUrl/api/auth/token" -H "Content-Type: application/json" -d "{\"token\":\"$($setupOk.token)\"}"
        } else {
            Write-Host "Owner account may already exist — trying login..."
            $loginResp = curl -s -c "$env:TEMP\jot-cookies.txt" -X POST "$JotUrl/api/auth/login" -H "Content-Type: application/json" -d "{\"password\":\"$JotPassword\"}"
            $loginOk = $loginResp | ConvertFrom-Json -ErrorAction SilentlyContinue
            if (-not $loginOk -or -not $loginOk.ok) {
                Write-Host "WARNING: Jot login failed. Set up manually after install."
                $jotFailed = $true
            }
        }

        Write-Host "Creating Jot API key..."
        $keyResp = curl -s -b "$env:TEMP\jot-cookies.txt" -X POST "$JotUrl/api/keys" -H "Content-Type: application/json" -d "{\"label\":\"$ApiKeyLabel\"}"
        $keyObj = $keyResp | ConvertFrom-Json -ErrorAction SilentlyContinue

        if ($keyObj -and $keyObj.key) {
            Write-Host "API key created successfully."
            jot register local $JotUrl $keyObj.key
            pm2 save
            Write-Host ""
            Write-Host "=== Jot Setup Complete ==="
            Write-Host "  URL: $JotUrl"
            Write-Host "  API Key: $($keyObj.key)"
            Write-Host "  Key ID: $($keyObj.id)"
            Write-Host ""
        } else {
            Write-Host "WARNING: Failed to create API key. Set up manually after install."
        }
    } else {
        Write-Host "curl or jq not found — skipping Jot API key generation."
    }
}

if (Test-Path "$env:TEMP\jot-cookies.txt") { Remove-Item "$env:TEMP\jot-cookies.txt" -Force }

# Phase 9 — Clone repo and copy skills
Write-Host "[9/10] Setting up research skills, subagent, and references..."
$VibeDir = "$env:USERPROFILE\vibe-research"
if (-not (Test-Path $VibeDir)) {
    Write-Host "Cloning vibe-research repository..."
    git clone https://github.com/udit-001/vibe-research.git $VibeDir
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARNING: Could not clone vibe-research repo."
        Write-Host "Clone it manually and copy skills to $env:USERPROFILE\.config\opencode\skills\"
    }
} else {
    Write-Host "vibe-research already exists at $VibeDir"
}

$OpencodeSkills = "$env:USERPROFILE\.config\opencode\skills"
$null = New-Item -Path $OpencodeSkills -ItemType Directory -Force

$allSkillsExist = (Test-Path "$OpencodeSkills\research\SKILL.md") -and
                  (Test-Path "$OpencodeSkills\search\SKILL.md") -and
                  (Test-Path "$OpencodeSkills\jot-collaboration\SKILL.md")
if ($allSkillsExist) {
    Write-Host "[9/10] Skills already copied. Skipping."
} else {
    if (Test-Path "$VibeDir\skills") {
        Write-Host "Copying skills to OpenCode..."
        Copy-Item -Path "$VibeDir\skills\*" -Destination $OpencodeSkills -Recurse -Force -ErrorAction SilentlyContinue
        if ($?) { Write-Host "Skills copied successfully." }
        else { Write-Host "WARNING: Could not copy skills." }
    }
}

$OpencodeAgents = "$env:USERPROFILE\.config\opencode\agents"
$null = New-Item -Path $OpencodeAgents -ItemType Directory -Force
if (Test-Path "$VibeDir\.opencode\agents") {
    Write-Host "Copying subagent to OpenCode..."
    Copy-Item -Path "$VibeDir\.opencode\agents\*" -Destination $OpencodeAgents -Recurse -Force -ErrorAction SilentlyContinue
    if ($?) { Write-Host "Subagent copied successfully." }
    else { Write-Host "WARNING: Could not copy subagent." }
}

$ResearchRefs = "$OpencodeSkills\research\references"
$null = New-Item -Path $ResearchRefs -ItemType Directory -Force
if (Test-Path "$VibeDir\skills\research\references\session-registry.md") {
    Write-Host "Copying session registry reference..."
    Copy-Item -Path "$VibeDir\skills\research\references\session-registry.md" -Destination $ResearchRefs -Force -ErrorAction SilentlyContinue
    if ($?) { Write-Host "Session registry reference copied." }
    else { Write-Host "WARNING: Could not copy session registry reference." }
}

$OpencodeConfig = "$env:USERPROFILE\.config\opencode\opencode.json"
$null = New-Item -Path "$env:USERPROFILE\.config\opencode" -ItemType Directory -Force
if (Test-Path $OpencodeConfig) {
    Write-Host "OpenCode config already exists at $OpencodeConfig — skipping (delete it to re-apply)"
} else {
    Write-Host "Copying opencode config (Exa MCP + web-researcher subagent)..."
    Copy-Item -Path "$VibeDir\config\opencode.json" -Destination $OpencodeConfig -Force -ErrorAction SilentlyContinue
    if ($?) { Write-Host "OpenCode config copied to $OpencodeConfig" }
    else { Write-Host "WARNING: Could not copy opencode config." }
}

Save-State 9

# Phase 10 — Zed Editor
Write-Host "[10/10] Installing Zed Editor..."
if (-not (Check-Installed zed)) {
    Write-Host "Installing Zed via winget..."
    winget install -e --id ZedIndustries.Zed
    if ($LASTEXITCODE -ne 0 -or -not (Check-Installed zed)) {
        Write-Host "WARNING: Could not install Zed. You can manually install it from https://zed.dev"
    }
    Write-Host "Zed installed successfully."
} else {
    Write-Host "Zed already installed."
}

Save-State 10

Write-Host ""
Write-Host "=== Setup complete! ==="
Write-Host ""
Write-Host "Summary:"
Write-Host "  - Windows Terminal: Installed and configured"
Write-Host "  - Git: Installed with 'oc' alias in .bashrc"
Write-Host "  - Git Bash: Set as default profile, starts in Dev\playground"
Write-Host "  - Theme: One Half Dark with default Windows Terminal font at 13pt"
Write-Host "  - Python 3.13 + uv + jq: Installed"
Write-Host "  - OpenCode: Installed with DCP plugin and Exa MCP"
Write-Host "  - PM2: Installed for process management"
Write-Host "  - Jot CLI: Installed (@mariozechner/jot) + auto-configured"
Write-Host "  - Jot Data: $JotDataDir"
Write-Host "  - Jot PM2 Config: $Pm2Config"
Write-Host "  - Skills: Copied to OpenCode skills directory"
Write-Host "  - Subagent: Copied to OpenCode agents directory"
Write-Host "  - Session Registry: Copied to research references"
Write-Host "  - Zed: Installed"
Write-Host "  - Dev\playground: Created"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Restart Windows Terminal (Git Bash)"
Write-Host "  2. Run: opencode --help"
Write-Host "  3. See $VibeDir\tools\jot\README.md for Jot usage"
Write-Host "  4. Run research session CLI: python `"$VibeDir\skills\research\tools\research_session.py`" --help"
Write-Host "  5. Manage Python packages: uv --help"
Write-Host "  6. Launch Zed: zed"
Write-Host "  7. Pull updates: git -C `"$VibeDir`" pull"
Write-Host ""
Write-Host "Repository: https://github.com/udit-001/vibe-research"
Write-Host ""
Read-Host "Press Enter to exit"
