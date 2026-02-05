$WshShell = New-Object -ComObject WScript.Shell
$StartupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\OpenClaw.lnk"
$Shortcut = $WshShell.CreateShortcut($StartupPath)
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = '-ExecutionPolicy Bypass -File "C:\projects\clawdbot\scripts\start-openclaw.ps1"'
$Shortcut.WorkingDirectory = "C:\projects\clawdbot"
$Shortcut.WindowStyle = 7  # Minimized
$Shortcut.Save()
Write-Host "Startup shortcut created at: $StartupPath"
