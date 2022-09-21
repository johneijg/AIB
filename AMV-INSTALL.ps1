Write-Host  -ForegroundColor Cyan "Gemeente Amstelveen Werkplek 365 - Stap 1: Reset van Windows"
Start-Sleep -Seconds 5

#Start OSDCloud ZTI the RIGHT way
Write-Host  -ForegroundColor Cyan "Start OSDCloud with Amstelveen Parameters"
Start-OSDCloud -findimage -ZTI -Restart

#Restart from WinPE
Write-Host  -ForegroundColor Cyan "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot