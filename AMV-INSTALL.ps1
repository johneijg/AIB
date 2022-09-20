Write-Host  -ForegroundColor Cyan "Gemeente Amstelveen Werkplek 365 - Stap 1: Reset van Windows"
Start-Sleep -Seconds 5

#Make sure I have the latest OSD Content
Write-Host  -ForegroundColor Cyan "Updating the OSD PowerShell Module"
Install-Module OSD -Force -SkipPublisherCheck

Write-Host  -ForegroundColor Cyan "Importing OSD PowerShell Module"
Import-Module OSD -Force

#Start OSDCloud ZTI the RIGHT way
Write-Host  -ForegroundColor Cyan "Start OSDCloud with Amstelveen Parameters"
Start-OSDCloud -OSName 'Windows 10 21H2 x64'-OSLanguage nl-nl -OSEdition Pro -ZTI -Restart

#Restart from WinPE
Write-Host  -ForegroundColor Cyan "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot