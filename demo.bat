@echo off
setlocal
cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
    echo Project setup is missing. Run scripts\bootstrap_windows.ps1 once.
    exit /b 1
)

".venv\Scripts\python.exe" demo.py
