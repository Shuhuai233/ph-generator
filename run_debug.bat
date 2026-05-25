@echo off
REM ============================================================
REM  PH Generator — Debug Launcher for Windows
REM ============================================================
REM
REM  Double-click this file to launch Godot with full debug
REM  output. All messages go to both the console window AND
REM  a timestamped log file that you can send to the AI.
REM
REM  What this does:
REM   1. Finds Godot.exe (checks GODOT_EXE env var, then PATH)
REM   2. Opens the project in editor mode with --verbose
REM   3. Captures ALL output to ph_debug_YYYYMMDD_HHMMSS.log
REM   4. When Godot closes, opens the log file
REM
REM  Usage:
REM   - Double-click run_debug.bat
REM   - OR from cmd: run_debug.bat
REM   - Set GODOT_EXE to point to a specific Godot binary:
REM     set GODOT_EXE=C:\Godot_v4.6.2-stable_win64.exe
REM ============================================================

setlocal enabledelayedexpansion

REM ── Configuration ───────────────────────────────────────────
set "GODOT_EXE=%GODOT_EXE%"

REM If GODOT_EXE is not set, try common locations
if "%GODOT_EXE%"=="" (
    REM Check if godot is on PATH
    where godot >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "delims=" %%i in ('where godot') do set "GODOT_EXE=%%i"
        echo [INFO] Found Godot on PATH: !GODOT_EXE!
    )
)

if "%GODOT_EXE%"=="" (
    echo [ERROR] Godot executable not found!
    echo.
    echo Please set GODOT_EXE to the path of Godot_v4.6.2-stable_win64.exe:
    echo   set GODOT_EXE=C:\Godot_v4.6.2-stable_win64.exe
    echo   run_debug.bat
    echo.
    pause
    exit /b 1
)

REM ── Validate Godot exists ───────────────────────────────────
if not exist "%GODOT_EXE%" (
    echo [ERROR] Godot not found at: %GODOT_EXE%
    echo Please download Godot 4.6.2 from:
    echo   https://godotengine.org/download/windows/
    pause
    exit /b 1
)

REM ── Create log file with timestamp ──────────────────────────
for /f "tokens=1-4 delims=/-: " %%a in ('echo %date% %time%') do (
    set "TS=%%a%%b%%c_%%d%%e%%f"
)
set "LOGFILE=ph_debug_%TS%.log"

echo ============================================================
echo  PH Generator — Debug Session
echo ============================================================
echo.
echo  Godot:    %GODOT_EXE%
echo  Project:  %CD%
echo  Log:      %LOGFILE%
echo.
echo  Starting Godot with --editor --verbose...
echo  (Close the Godot window to stop logging)
echo ============================================================
echo.

REM ── Launch Godot in editor mode with verbose logging ────────
REM    --editor     : open in editor mode (loads EditorPlugins)
REM    --verbose    : maximum debug output
REM    2>&1         : merge stderr into stdout
REM    | tee        : show on console AND write to file
"%GODOT_EXE%" --editor --verbose --path "%CD%" 2>&1 | "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -Command "$input | Tee-Object -FilePath '%LOGFILE%'"

REM ── Capture exit code ───────────────────────────────────────
set "EXIT_CODE=%errorlevel%"

echo.
echo ============================================================
echo  Godot exited with code: %EXIT_CODE%
echo  Full log saved to: %CD%\%LOGFILE%
echo.
echo  To share with the AI, attach this file:
echo    %CD%\%LOGFILE%
echo ============================================================

REM ── Prompt to open log ──────────────────────────────────────
echo.
set /p OPENLOG="Open log file in Notepad? (Y/N): "
if /i "%OPENLOG%"=="Y" (
    start notepad "%LOGFILE%"
)
if /i "%OPENLOG%"=="" (
    echo Log file: %CD%\%LOGFILE%
)

pause
exit /b %EXIT_CODE%
