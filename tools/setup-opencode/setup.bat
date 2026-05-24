@echo off
setlocal enabledelayedexpansion

set "STATE_DIR=%USERPROFILE%\.opencode-setup"
set "STATE_FILE=%STATE_DIR%\state.txt"
if not exist "%STATE_DIR%" mkdir "%STATE_DIR%"

set STATE=0
if exist "%STATE_FILE%" set /p STATE=<"%STATE_FILE%"

if %STATE%==10 (
    echo === OpenCode + Python/uv/jq + Jot + Skills + Zed are already installed ===
    echo Run: opencode --help to get started.
    echo Run: jot --help to see jot commands.
    echo Run: zed --help to see Zed commands.
    pause
    exit /b 0
)

echo === OpenCode + Python/uv/jq + Jot + Skills + Zed Windows Setup ===
echo.
echo Repository: https://github.com/udit-001/vibe-research
echo.

:: Phase 0 — Windows Terminal (REQUIRED)
where wt >nul 2>&1
if !errorlevel! neq 0 (
    echo [0/10] Installing Windows Terminal via winget...
    winget install --id Microsoft.WindowsTerminal -e
    if !errorlevel! neq 0 (
        echo FAILED. Windows Terminal is required for this setup.
        pause
        exit /b 1
    )
    echo Windows Terminal installed. Close this terminal and open Windows Terminal, then run this script again.
    pause
    exit /b 0
) else (
    echo Windows Terminal already installed.
)

echo.

:: Phase 1 — Git
where git >nul 2>&1
if !errorlevel! neq 0 (
    echo [1/10] Installing Git via winget...
    winget install -e --id Git.Git
    if !errorlevel! neq 0 (
        echo FAILED.
        pause
        exit /b 1
    )
    echo 1 > "%STATE_FILE%"
    echo.
    echo Done. Close this terminal and open a new one, then run this script again.
    pause
    exit /b 0
)

:: Setup .bashrc with opencode alias after Git is installed
set "BASHRC=%USERPROFILE%\.bashrc"
if not exist "%BASHRC%" (
    echo # Git Bash configuration > "%BASHRC%"
)
findstr /C:"alias oc=" "%BASHRC%" >nul 2>&1
if !errorlevel! neq 0 (
    echo. >> "%BASHRC%"
    echo # OpenCode alias >> "%BASHRC%"
    echo alias oc='opencode' >> "%BASHRC%"
    echo Added 'oc' alias to %BASHRC%
)

:: Phase 2 — Node.js
where node >nul 2>&1
if !errorlevel! neq 0 (
    echo [2/10] Installing Node.js via winget...
    winget install -e --id OpenJS.NodeJS.LTS
    if !errorlevel! neq 0 (
        echo FAILED.
        pause
        exit /b 1
    )
    echo 2 > "%STATE_FILE%"
    echo.
    echo Done. Close this terminal and open a new one, then run this script again.
    pause
    exit /b 0
)

:: Phase 3 — Python + uv (REQUIRED for research skills)
where python >nul 2>&1
if !errorlevel! neq 0 (
    echo [3/10] Installing Python 3.13...
    winget install -e --id Python.Python.3.13
    if !errorlevel! neq 0 (
        echo FAILED.
        pause
        exit /b 1
    )
    echo 3 > "%STATE_FILE%"
    echo.
    echo Done. Close this terminal and open a new one, then run this script again.
    pause
    exit /b 0
)
where uv >nul 2>&1
if !errorlevel! neq 0 winget install -e --id astral-sh.uv >nul 2>&1
where uv >nul 2>&1
if !errorlevel! neq 0 pip install uv >nul 2>&1
where uv >nul 2>&1
if !errorlevel! neq 0 echo WARNING: Could not install uv. Install later with: pip install uv

where jq >nul 2>&1
if !errorlevel! neq 0 winget install -e --id jqlang.jq >nul 2>&1
where jq >nul 2>&1
if !errorlevel! neq 0 echo WARNING: Could not install jq. Install later with: winget install jqlang.jq

:: Phase 4 — OpenCode
where opencode >nul 2>&1
if !errorlevel! neq 0 (
    echo [4/10] Installing OpenCode...
    npm install -g opencode-ai --no-fund --no-audit 2>&1
    where opencode >nul 2>&1
    if !errorlevel! neq 0 (
        echo FAILED.
        pause
        exit /b 1
    )
) else (
    echo [4/10] OpenCode already installed. Skipping.
)
echo 4 > "%STATE_FILE%"

:: Phase 5 — OpenCode DCP plugin
echo [5/10] DCP plugin is configured in config/opencode.json (auto-installed on next opencode start). Skipping.
echo 5 > "%STATE_FILE%"

echo.
echo === OpenCode installed successfully! ===
echo Run: opencode --help to get started.
echo.

:: Create Dev/playground directory structure
if not exist "%USERPROFILE%\Dev" mkdir "%USERPROFILE%\Dev"
if not exist "%USERPROFILE%\Dev\playground" mkdir "%USERPROFILE%\Dev\playground"
echo Created: %USERPROFILE%\Dev\playground
echo.

:: Configure Windows Terminal with Git Bash profile, theme, and settings
echo Configuring Windows Terminal...
echo Downloading config template...
powershell -ExecutionPolicy Bypass -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/udit-001/vibe-research/master/tools/setup-opencode/wt-settings.json', '%TEMP%\wt-settings.json')"
if not exist "%TEMP%\wt-settings.json" (
    echo WARNING: Could not download Windows Terminal config template.
    goto :wt_done
)
echo Downloading merge script...
powershell -ExecutionPolicy Bypass -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/udit-001/vibe-research/master/tools/setup-opencode/merge-wt-config.py', '%TEMP%\merge-wt-config.py')"
if not exist "%TEMP%\merge-wt-config.py" (
    echo WARNING: Could not download merge script.
    goto :wt_cleanup
)
python "%TEMP%\merge-wt-config.py" "%TEMP%\wt-settings.json" "%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" "%USERPROFILE%\Dev\playground"
if !errorlevel! equ 0 (
    echo Windows Terminal configured: Git Bash as default profile
) else (
    echo WARNING: Failed to configure Windows Terminal.
)
:wt_cleanup
del "%TEMP%\wt-settings.json" 2>nul
del "%TEMP%\merge-wt-config.py" 2>nul
:wt_done

:: Phase 6 — PM2 (for Jot process management)
where pm2 >nul 2>&1
if !errorlevel! neq 0 (
    echo [6/10] Installing PM2...
    call npm install -g pm2
    if !errorlevel! neq 0 (
        echo FAILED.
        pause
        exit /b 1
    )
) else (
    echo [6/10] PM2 already installed. Skipping.
)
echo 6 > "%STATE_FILE%"

:: Phase 7 — Jot CLI
where jot >nul 2>&1
if !errorlevel! neq 0 (
    echo [7/10] Installing Jot CLI...
    call npm install -g @mariozechner/jot
    if !errorlevel! neq 0 (
        echo FAILED.
        pause
        exit /b 1
    )
) else (
    echo [7/10] Jot CLI already installed. Skipping.
)
echo 7 > "%STATE_FILE%"

:: Phase 8 — Clone vibe-research repo and sync skills + subagent + config via Python
echo [8/10] Setting up research skills, subagent, and references...
set "VIBE_DIR=%USERPROFILE%\vibe-research"
if not exist "%VIBE_DIR%" (
    echo Cloning vibe-research repository...
    git clone https://github.com/udit-001/vibe-research.git "%VIBE_DIR%"
)
if not exist "%VIBE_DIR%" (
    echo WARNING: Could not clone vibe-research repo.
    echo You can manually clone it later and copy skills to %%USERPROFILE%%\.config\opencode\skills\
    goto :skills_done
)

:: Download and run sync script
powershell -ExecutionPolicy Bypass -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/udit-001/vibe-research/master/tools/setup-opencode/sync-skills.py', '%TEMP%\sync-skills.py')"
if exist "%TEMP%\sync-skills.py" (
    python "%TEMP%\sync-skills.py"
    del "%TEMP%\sync-skills.py" 2>nul
) else (
    echo WARNING: Could not download sync-skills.py.
)

:skills_done
echo 8 > "%STATE_FILE%"

:: Phase 9 — Zed Editor
echo [9/10] Installing Zed Editor...
where zed >nul 2>&1
if !errorlevel! neq 0 (
    echo Installing Zed via winget...
    winget install -e --id ZedIndustries.Zed
    if !errorlevel! neq 0 (
        echo WARNING: Could not install Zed via winget.
        echo You can manually install it from https://zed.dev
        goto :zed_done
    )
    echo Zed installed successfully.
) else (
    echo Zed already installed.
)

:zed_done
echo 9 > "%STATE_FILE%"

:: Phase 10 — Jot Data Directory and PM2 Config
echo [10/10] Setting up Jot server, data directory, and API key...
set "JOT_DATA_DIR=%USERPROFILE%\jot-data"
if not exist "%JOT_DATA_DIR%\logs" mkdir "%JOT_DATA_DIR%\logs"

set "PM2_CONFIG=%USERPROFILE%\jot-pm2.json"
echo Downloading PM2 config generator...
powershell -ExecutionPolicy Bypass -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/udit-001/vibe-research/master/tools/setup-opencode/gen-jot-pm2-config.py', '%TEMP%\gen-jot-pm2-config.py')"
if not exist "%TEMP%\gen-jot-pm2-config.py" (
    echo WARNING: Could not download PM2 config generator. Jot setup skipped.
    goto :jot_done
)
python "%TEMP%\gen-jot-pm2-config.py" "%PM2_CONFIG%" "%JOT_DATA_DIR%" 3210
if !errorlevel! neq 0 (
    echo WARNING: Could not generate PM2 config. Jot setup skipped.
    goto :jot_done
)
del "%TEMP%\gen-jot-pm2-config.py" 2>nul
echo Jot PM2 config ready at %PM2_CONFIG%

where pm2 >nul 2>&1
if !errorlevel! neq 0 (
    echo PM2 not found on PATH — Jot server auto-start skipped.
    goto :jot_done
)

echo Starting Jot server...
pm2 delete jot 2>nul
pm2 start "%PM2_CONFIG%"
if !errorlevel! neq 0 (
    echo FAILED to start Jot server. After setup, run: pm2 start %PM2_CONFIG%
    goto :jot_done
)

echo Waiting for Jot server to be ready...
%WINDIR%\System32\timeout.exe /t 5 /nobreak >nul

:: Create owner account and API key
where curl >nul 2>&1
if !errorlevel! neq 0 (
    echo curl not found — skipping API key generation.
    goto :jot_done
)
where jq >nul 2>&1
if !errorlevel! neq 0 (
    echo jq not found — Jot API key setup skipped (optional: restart terminal after jq install).
    goto :jot_done
)

set "JOT_URL=http://localhost:3210"
set "JOT_PASSWORD=12345678"
set "API_KEY_LABEL=opencode-skill"

echo Creating Jot owner account...
for /f "usebackq delims=" %%r in (`curl -s -X POST "%JOT_URL%/api/auth/setup" -H "Content-Type: application/json" -d "{\"password\":\"%JOT_PASSWORD%\",\"confirmPassword\":\"%JOT_PASSWORD%\""`) do set "SETUP_RESPONSE=%%r"
echo %SETUP_RESPONSE% | jq -e ".token" >nul 2>&1
if !errorlevel! neq 0 (
    echo Owner account may already exist — trying login...
    for /f "usebackq delims=" %%r in (`curl -s -c "%TEMP%\jot-cookies.txt" -X POST "%JOT_URL%/api/auth/login" -H "Content-Type: application/json" -d "{\"password\":\"%JOT_PASSWORD%\""`) do set "LOGIN_RESPONSE=%%r"
    echo %LOGIN_RESPONSE% | jq -e ".ok" >nul 2>&1
    if !errorlevel! neq 0 (
        echo WARNING: Jot login failed. Set up manually after install.
        goto :jot_api_done
    )
) else (
    echo Owner account created. Exchanging device token...
    for /f %%t in ('echo %SETUP_RESPONSE% ^| jq -r ".token"') do set "DEVICE_TOKEN=%%t"
    curl -s -c "%TEMP%\jot-cookies.txt" -X POST "%JOT_URL%/api/auth/token" -H "Content-Type: application/json" -d "{\"token\":\"%DEVICE_TOKEN%\"}" >nul
)

echo Creating Jot API key...
for /f "usebackq delims=" %%r in (`curl -s -b "%TEMP%\jot-cookies.txt" -X POST "%JOT_URL%/api/keys" -H "Content-Type: application/json" -d "{\"label\":\"%API_KEY_LABEL%\"}"`) do set "KEY_RESPONSE=%%r"
for /f %%k in ('echo %KEY_RESPONSE% ^| jq -r ".key"') do set "API_KEY=%%k"
for /f %%i in ('echo %KEY_RESPONSE% ^| jq -r ".id"') do set "KEY_ID=%%i"

if "%API_KEY%"=="" (
    echo WARNING: Failed to create API key. Set up manually after install.
    goto :jot_api_done
)
echo API key created successfully.

echo Registering Jot CLI...
jot register local "%JOT_URL%" "%API_KEY%"
if !errorlevel! equ 0 (
    echo Jot CLI registration successful.
) else (
    echo WARNING: CLI registration may have issues — API key is still valid.
)

pm2 save
echo.
echo === Jot Setup Complete ===
echo   URL: %JOT_URL%
echo   API Key: %API_KEY%
echo   Key ID: %KEY_ID%
echo.

:jot_api_done
if exist "%TEMP%\jot-cookies.txt" del "%TEMP%\jot-cookies.txt"

:jot_done
echo 10 > "%STATE_FILE%"

echo.
echo === Setup complete! ===
echo.
echo Summary:
echo   - Windows Terminal: Installed and configured
echo   - Git: Installed with 'oc' alias in .bashrc
echo   - Git Bash: Set as default profile, starts in Dev\playground
echo   - Theme: One Half Dark with default Windows Terminal font at 13pt
echo   - Python 3.13 + uv + jq: Installed
echo   - OpenCode: Installed with DCP plugin and Exa MCP
echo   - PM2: Installed for process management
echo   - Jot CLI: Installed (@mariozechner/jot) + auto-configured
echo   - Skills: Copied to OpenCode skills directory
echo   - Subagent: Copied to OpenCode agents directory
echo   - Session Registry: Copied to research references
echo   - Zed: Installed
echo   - Dev\playground: Created
echo.
echo Next steps:
echo   1. Restart Windows Terminal (Git Bash)
echo   2. Run: opencode --help
echo   3. Run research session CLI: python "%VIBE_DIR%\skills\research\tools\research_session.py" --help
echo   4. Manage Python packages: uv --help
echo   5. Launch Zed: zed
echo   6. See %VIBE_DIR%\tools\jot\README.md for Jot usage
echo   7. Pull updates: git -C "%VIBE_DIR%" pull
echo.
echo Repository: https://github.com/udit-001/vibe-research
echo.
pause