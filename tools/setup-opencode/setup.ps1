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
$MergeScriptUrl = "https://raw.githubusercontent.com/udit-001/vibe-research/master/tools/setup-opencode/merge-wt-config.py"
$TemplatePath = "$env:TEMP\wt-settings.json"
$MergeScriptPath = "$env:TEMP\merge-wt-config.py"

try {
    $web = New-Object Net.WebClient
    $web.DownloadFile($TemplateUrl, $TemplatePath)
    $web.DownloadFile($MergeScriptUrl, $MergeScriptPath)
    python $MergeScriptPath $TemplatePath $WtSettings "$env:USERPROFILE\Dev\playground"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Windows Terminal configured: Git Bash as default profile"
    }
} catch {
    Write-Host "WARNING: Could not configure Windows Terminal."
    Write-Host "You can manually configure Windows Terminal: set Git Bash as default profile."
} finally {
    Remove-Item $TemplatePath -ErrorAction SilentlyContinue
    Remove-Item $MergeScriptPath -ErrorAction SilentlyContinue
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

# Phase 8 — Clone repo and sync skills + subagent + config via Python
Write-Host "[8/10] Setting up research skills, subagent, and references..."
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

# Download and run sync script
$ScriptUrl = "https://raw.githubusercontent.com/udit-001/vibe-research/master/tools/setup-opencode/sync-skills.py"
$ScriptPath = "$env:TEMP\sync-skills.py"
try {
    (New-Object Net.WebClient).DownloadFile($ScriptUrl, $ScriptPath)
    if (Test-Path $ScriptPath) {
        python $ScriptPath
        Remove-Item $ScriptPath -Force
    }
} catch {
    Write-Host "WARNING: Could not download sync-skills.py. Run setup from the beginning."
}

Save-State 8

# Phase 9 — Zed Editor
Write-Host "[9/10] Installing Zed Editor..."
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

Save-State 9

# Phase 10 — Jot Setup (optional, last — skips gracefully if dependencies missing)
Write-Host "[10/10] Setting up Jot server, data directory, and API key..."
$JotDataDir = "$env:USERPROFILE\jot-data"
$null = New-Item -Path "$JotDataDir\logs" -ItemType Directory -Force

$Pm2Config = "$env:USERPROFILE\jot-pm2.json"
$GenScriptUrl = "https://raw.githubusercontent.com/udit-001/vibe-research/master/tools/setup-opencode/gen-jot-pm2-config.py"
$GenScriptPath = "$env:TEMP\gen-jot-pm2-config.py"

try {
    (New-Object Net.WebClient).DownloadFile($GenScriptUrl, $GenScriptPath)
} catch {
    Write-Host "WARNING: Could not download PM2 config generator."
}

if (Test-Path $GenScriptPath) {
    python $GenScriptPath $Pm2Config $JotDataDir 3210
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Created PM2 config at $Pm2Config"
    } else {
        Write-Host "WARNING: Could not generate PM2 config."
    }
    Remove-Item $GenScriptPath -Force -ErrorAction SilentlyContinue
}

if (-not (Check-Installed pm2)) {
    Write-Host "PM2 not found on PATH — Jot server auto-start skipped."
} else {
    Write-Host "Starting Jot server..."
    pm2 delete jot 2>$null
    pm2 start $Pm2Config
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
}

if (Test-Path "$env:TEMP\jot-cookies.txt") { Remove-Item "$env:TEMP\jot-cookies.txt" -Force }

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
Write-Host "  3. Run research session CLI: python `"$VibeDir\skills\research\tools\research_session.py`" --help"
Write-Host "  4. Manage Python packages: uv --help"
Write-Host "  5. Launch Zed: zed"
Write-Host "  6. See $VibeDir\tools\jot\README.md for Jot usage"
Write-Host "  7. Pull updates: git -C `"$VibeDir`" pull"
Write-Host ""
Write-Host "Repository: https://github.com/udit-001/vibe-research"
Write-Host ""
Read-Host "Press Enter to exit"
