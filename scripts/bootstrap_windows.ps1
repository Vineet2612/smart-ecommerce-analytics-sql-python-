# Run from the project root in PowerShell: .\scripts\bootstrap_windows.ps1

if (-not (Get-Command py -ErrorAction SilentlyContinue)) {
    throw "Python was not found. Install Python 3.10+ from python.org, select 'Add Python to PATH', and run this script again."
}

if (-not (Test-Path ".venv")) {
    py -m venv .venv
}

& ".\.venv\Scripts\python.exe" -m pip install --upgrade pip
& ".\.venv\Scripts\python.exe" -m pip install -e ".[dev]"

if (-not (Test-Path ".env")) {
    Copy-Item -LiteralPath ".env.example" -Destination ".env"
    Write-Output "Created .env. Open it and enter your MySQL username and password."
}

Write-Output "Python setup complete. Next: mysql -u root -p < sql/setup.sql"

