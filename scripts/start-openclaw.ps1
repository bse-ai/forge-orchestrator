# OpenClaw Startup Script
# Launches gateway and TUI in separate windows

$scriptDir = "C:\projects\clawdbot\scripts"

# Start Gateway in new window
Start-Process powershell -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", "$scriptDir\launch-gateway.ps1" -WindowStyle Normal

# Wait for gateway to start
Start-Sleep -Seconds 3

# Start TUI in new window
Start-Process powershell -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", "$scriptDir\launch-tui.ps1" -WindowStyle Normal
