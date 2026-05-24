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
echo [5/10] Installing opencode plugin @tarquinen/opencode-dcp...
set "GLOBAL_OC_CONFIG=%USERPROFILE%\.config\opencode\opencode.json"
findstr "opencode-dcp" "%GLOBAL_OC_CONFIG%" >nul 2>&1
if !errorlevel! neq 0 (
    opencode plugin @tarquinen/opencode-dcp@latest --global
    findstr "opencode-dcp" "%GLOBAL_OC_CONFIG%" >nul 2>&1
    if !errorlevel! neq 0 (
        echo FAILED.
        pause
        exit /b 1
    )
) else (
    echo [5/10] DCP plugin already installed. Skipping.
)
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
set "WT_SETTINGS=%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if not exist "%WT_SETTINGS%" (
    echo Windows Terminal settings.json not found at expected location.
    echo Skipping Windows Terminal configuration.
    goto :wt_done
)

echo Configuring Windows Terminal...

:: Create a PowerShell script to modify settings.json
set "PS_SCRIPT=%TEMP%\wt-config.ps1"
(
echo $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
echo $json = Get-Content $settingsPath -Raw ^| ConvertFrom-Json -Depth 100
echo.
echo # Generate a GUID for Git Bash profile
echo $gitBashGuid = "{00000000-0000-0000-0000-000000000001}"
echo.
echo # Check if Git Bash profile already exists
echo $existingProfile = $json.profiles.list ^| Where-Object { $_.name -eq "Git Bash" }
echo if (-not $existingProfile) {
echo     $gitBashProfile = @{
echo         guid = $gitBashGuid
echo         name = "Git Bash"
echo         commandline = "`"C:\Program Files\Git\bin\bash.exe`" -li"
echo         icon = "`"C:\Program Files\Git\mingw64\share\git\git-for-windows.ico`""
echo         startingDirectory = "`"%USERPROFILE%\Dev\playground`""
echo         hidden = $false
echo     }
echo     $json.profiles.list += $gitBashProfile
echo     Write-Host "Added Git Bash profile"
echo } else {
echo     $existingProfile.startingDirectory = "`"%USERPROFILE%\Dev\playground`""
echo     Write-Host "Updated Git Bash starting directory"
echo }
echo.
echo # Set Git Bash as default profile
echo $json.defaultProfile = $gitBashGuid
echo Write-Host "Set Git Bash as default profile"
echo.
echo # Add One Half Dark color scheme if not exists
echo $oneHalfDark = @{
echo     name = "One Half Dark"
echo     background = "#282C34"
echo     foreground = "#DCDFE4"
echo     black = "#282C34"
echo     red = "#E06C75"
echo     green = "#98C379"
echo     yellow = "#E5C07B"
echo     blue = "#61AFEF"
echo     purple = "#C678DD"
echo     cyan = "#56B6C2"
echo     white = "#DCDFE4"
echo     brightBlack = "#5A6374"
echo     brightRed = "#E06C75"
echo     brightGreen = "#98C379"
echo     brightYellow = "#E5C07B"
echo     brightBlue = "#61AFEF"
echo     brightPurple = "#C678DD"
echo     brightCyan = "#56B6C2"
echo     brightWhite = "#DCDFE4"
echo     cursorColor = "#A3B3CC"
echo     selectionBackground = "#3E4451"
echo }
echo.
echo if (-not $json.schemes) {
echo     $json ^| Add-Member -NotePropertyName schemes -NotePropertyValue @($oneHalfDark)
echo     Write-Host "Added One Half Dark color scheme"
echo } else {
echo     $existingScheme = $json.schemes ^| Where-Object { $_.name -eq "One Half Dark" }
echo     if (-not $existingScheme) {
echo         $json.schemes += $oneHalfDark
echo         Write-Host "Added One Half Dark color scheme"
echo     }
echo }
echo.
echo # Apply theme and font to defaults
echo if (-not $json.profiles.defaults) {
echo     $json.profiles ^| Add-Member -NotePropertyName defaults -NotePropertyValue @{
echo         colorScheme = "One Half Dark"
echo         font = @{
echo             size = 13
echo         }
echo         useAcrylic = $true
echo         acrylicOpacity = 0.85
echo         padding = "8"
echo     }
echo } else {
echo     $json.profiles.defaults.colorScheme = "One Half Dark"
echo     $json.profiles.defaults.font = @{
echo         size = 13
echo     }
echo     $json.profiles.defaults.useAcrylic = $true
echo     $json.profiles.defaults.acrylicOpacity = 0.85
echo     $json.profiles.defaults.padding = "8"
echo }
echo Write-Host "Applied theme and font settings"
echo.
echo # Save settings
echo $json ^| ConvertTo-Json -Depth 100 ^| Set-Content $settingsPath
echo Write-Host "Windows Terminal configuration saved"
) > "%PS_SCRIPT%"

powershell -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
del "%PS_SCRIPT%"

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

:: Phase 8 — Jot Data Directory and PM2 Config
echo [8/10] Setting up Jot data directory and PM2 config...
set "JOT_DATA_DIR=%USERPROFILE%\jot-data"
if not exist "%JOT_DATA_DIR%\logs" mkdir "%JOT_DATA_DIR%\logs"

:: Create PM2 ecosystem file for Jot
set "PM2_CONFIG=%USERPROFILE%\jot-pm2.json"
if exist "%PM2_CONFIG%" (
    echo Jot PM2 config already exists at %PM2_CONFIG%
    goto :pm2_config_done
)
(
echo {
echo   "apps": [{
echo     "name": "jot",
echo     "script": "jot",
echo     "args": ["serve", "--port=3210", "--data=%JOT_DATA_DIR%"],
echo     "instances": 1,
echo     "exec_mode": "fork",
echo     "env": {
echo       "NODE_ENV": "production"
echo     },
echo     "log_file": "%JOT_DATA_DIR%\\logs\\combined.log",
echo     "out_file": "%JOT_DATA_DIR%\\logs\\out.log",
echo     "error_file": "%JOT_DATA_DIR%\\logs\\error.log",
echo     "autorestart": true,
echo     "max_restarts": 10,
echo     "min_uptime": "10s"
echo   }]
echo }
) > "%PM2_CONFIG%"
:pm2_config_done
echo Jot PM2 config ready at %PM2_CONFIG%
echo 8 > "%STATE_FILE%"

:: Start Jot server
where pm2 >nul 2>&1
if !errorlevel! neq 0 (
    echo PM2 not found on PATH. Close this terminal, open a new one, and run this script again.
    pause
    exit /b 0
)
where jot >nul 2>&1
if !errorlevel! neq 0 (
    echo Jot CLI not found on PATH. Close this terminal, open a new one, and run this script again.
    pause
    exit /b 0
)

echo Starting Jot server...
pm2 start "%PM2_CONFIG%" 2>nul || pm2 restart jot
if !errorlevel! neq 0 (
    echo FAILED to start Jot server. After setup, run: pm2 start %PM2_CONFIG%
    goto :jot_api_done
)

echo Waiting for Jot server to be ready...
%WINDIR%\System32\timeout.exe /t 5 /nobreak >nul

:: Create owner account and API key
echo Setting up Jot authentication...
where curl >nul 2>&1
if !errorlevel! neq 0 (
    echo curl not found — skipping API key generation.
    echo After setup, run: tools\jot\setup-api-key.sh (Git Bash) or see tools\jot\README.md
    goto :jot_api_done
)
where jq >nul 2>&1
if !errorlevel! neq 0 (
    echo jq not found on PATH. Close this terminal, open a new one, and run this script again.
    pause
    exit /b 0
)

set "JOT_URL=http://localhost:3210"
set "JOT_PASSWORD=12345678"
set "API_KEY_LABEL=opencode-skill"

:: Setup owner account
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

:: Create API key
echo Creating Jot API key...
for /f "usebackq delims=" %%r in (`curl -s -b "%TEMP%\jot-cookies.txt" -X POST "%JOT_URL%/api/keys" -H "Content-Type: application/json" -d "{\"label\":\"%API_KEY_LABEL%\"}"`) do set "KEY_RESPONSE=%%r"
for /f %%k in ('echo %KEY_RESPONSE% ^| jq -r ".key"') do set "API_KEY=%%k"
for /f %%i in ('echo %KEY_RESPONSE% ^| jq -r ".id"') do set "KEY_ID=%%i"

if "%API_KEY%"=="" (
    echo WARNING: Failed to create API key. Set up manually after install.
    goto :jot_api_done
)

echo API key created successfully.

:: Register CLI
echo Registering Jot CLI...
jot register local "%JOT_URL%" "%API_KEY%"
if !errorlevel! equ 0 (
    echo Jot CLI registration successful.
) else (
    echo WARNING: CLI registration may have issues — API key is still valid.
)

:: Save PM2 config
pm2 save

echo.
echo === Jot Setup Complete ===
echo   URL: %JOT_URL%
echo   API Key: %API_KEY%
echo   Key ID: %KEY_ID%
echo.

:jot_api_done
if exist "%TEMP%\jot-cookies.txt" del "%TEMP%\jot-cookies.txt"

:: Phase 9 — Clone vibe-research repo and copy skills + subagent + references to OpenCode
echo [9/10] Setting up research skills, subagent, and references...
set "VIBE_DIR=%USERPROFILE%\vibe-research"
if not exist "%VIBE_DIR%" (
    echo Cloning vibe-research repository...
    git clone https://github.com/udit-001/vibe-research.git "%VIBE_DIR%"
    if !errorlevel! neq 0 (
        echo WARNING: Could not clone vibe-research repo.
        echo You can manually clone it later and copy skills to %%USERPROFILE%%\.config\opencode\skills\
        goto :skills_done
    )
) else (
    echo vibe-research already exists at %VIBE_DIR%
)

:: Copy skills to OpenCode's skills directory
set "OPENCODE_SKILLS=%USERPROFILE%\.config\opencode\skills"
if not exist "%OPENCODE_SKILLS%" mkdir "%OPENCODE_SKILLS%"

if exist "%OPENCODE_SKILLS%\research\SKILL.md" if exist "%OPENCODE_SKILLS%\search\SKILL.md" if exist "%OPENCODE_SKILLS%\jot-collaboration\SKILL.md" (
    echo [9/10] Skills already copied. Skipping.
    goto :skills_done
)

if exist "%VIBE_DIR%\skills" (
    echo Copying skills to OpenCode...
    xcopy /E /I /Y "%VIBE_DIR%\skills\*" "%OPENCODE_SKILLS%\" >nul 2>&1
    if !errorlevel! equ 0 (
        echo Skills copied successfully.
    ) else (
        echo WARNING: Could not copy skills. You may need to copy them manually.
    )
)

:: Copy subagent to OpenCode's agents directory
set "OPENCODE_AGENTS=%USERPROFILE%\.config\opencode\agents"
if not exist "%OPENCODE_AGENTS%" mkdir "%OPENCODE_AGENTS%"

if exist "%VIBE_DIR%\.opencode\agents" (
    echo Copying subagent to OpenCode...
    xcopy /E /I /Y "%VIBE_DIR%\.opencode\agents\*" "%OPENCODE_AGENTS%\" >nul 2>&1
    if !errorlevel! equ 0 (
        echo Subagent copied successfully.
    ) else (
        echo WARNING: Could not copy subagent. You may need to copy it manually.
    )
)

:: Copy session registry reference to research skill references
set "RESEARCH_REFS=%OPENCODE_SKILLS%\research\references"
if not exist "%RESEARCH_REFS%" mkdir "%RESEARCH_REFS%"

if exist "%VIBE_DIR%\skills\research\references\session-registry.md" (
    echo Copying session registry reference...
    copy /Y "%VIBE_DIR%\skills\research\references\session-registry.md" "%RESEARCH_REFS%\" >nul 2>&1
    if !errorlevel! equ 0 (
        echo Session registry reference copied.
    ) else (
        echo WARNING: Could not copy session registry reference.
    )
)

:: Copy opencode config (Exa MCP + web-researcher subagent)
set "OPENCODE_CONFIG=%USERPROFILE%\.config\opencode\opencode.json"
if not exist "%USERPROFILE%\.config\opencode" mkdir "%USERPROFILE%\.config\opencode"
if exist "%OPENCODE_CONFIG%" (
    echo OpenCode config already exists at %OPENCODE_CONFIG% — skipping (delete it to re-apply)
) else (
    echo Copying opencode config (Exa MCP + web-researcher subagent)...
    copy /Y "%VIBE_DIR%\config\opencode.json" "%OPENCODE_CONFIG%" >nul 2>&1
    if !errorlevel! equ 0 (
        echo OpenCode config copied to %OPENCODE_CONFIG%
    ) else (
        echo WARNING: Could not copy opencode config.
    )
)

:skills_done
echo 9 > "%STATE_FILE%"

:: Phase 10 — Zed Editor
echo [10/10] Installing Zed Editor...
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
echo   - Jot Data: %JOT_DATA_DIR%
echo   - Jot PM2 Config: %PM2_CONFIG%
echo   - Skills: Copied to OpenCode skills directory
echo   - Subagent: Copied to OpenCode agents directory
echo   - Session Registry: Copied to research references
echo   - Zed: Installed
echo   - Dev\playground: Created
echo.
echo Next steps:
echo   1. Restart Windows Terminal (Git Bash)
echo   2. Run: opencode --help
echo   3. See %VIBE_DIR%\tools\jot\README.md for Jot usage
echo   4. Run research session CLI: python "%VIBE_DIR%\skills\research\tools\research_session.py" --help
echo   5. Manage Python packages: uv --help
echo   6. Launch Zed: zed
echo   7. Pull updates: git -C "%VIBE_DIR%" pull
echo.
echo Repository: https://github.com/udit-001/vibe-research
echo.
pause