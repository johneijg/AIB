<#
Script purpose: Optimize AVD Image
Version: 1.0
Date: 18-01-2022
Author: John Eijgensteijn
Change log: First release
#>

#region Variables
$TempPath="c:\Temp\Software"
$LogPath="C:\Programdata\PPC\"
$Logfile="Software_Install.log"
#repo for app installation parameters
$repo="https://dev.azure.com/ProactBenelux/d4523fbb-bde0-48ff-9be6-e3fb84165b1a/_apis/git/repositories/92abb40d-73cf-49ef-9a5c-cbed18018b12/items?path="
$storageaccount="https://ppcavdstorage.blob.core.windows.net/avdbuild?sp=r&st=2022-02-24T08:31:07Z&se=2023-02-24T16:31:07Z&spr=https&sv=2020-08-04&sr=c&sig=8NGsByN%2BkHPpTsFIZvRubQ%2FqfN1c1Hig7pDAyqXmZfo%3D"

#region create folders
#Create folder for Logfile storage
#Create Temp folder for Software download and Extract
try {
        If (!(Test-path -Path $TempPath -ErrorAction Ignore)) {New-Item -ItemType Directory $TempPath }
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Output "Error creating temp folder $ErrorMessage"
}

If (!(Test-Path -Path $LogPath -ErrorAction Ignore)) {New-Item -ItemType Directory $LogPath }

#Create folder for Languagefile storage
try {
        $LanguagePath=$TempPath+"\nl"
        If (!(Test-Path -Path $LanguagePath -ErrorAction Ignore)) {New-Item -ItemType Directory $LanguagePath}

}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Output "Error creating Log folder $ErrorMessage"
}
#endregion create folders

#region Optimize AVD
try {#Enable RDP Shortpath","Description":"This script enables the preview function for RDP Shortpath on the selected session hosts
       $WinstationsKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'
                New-ItemProperty -Path $WinstationsKey -Name 'fUseUdpPortRedirector' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 1 -Force -Verbose
                New-ItemProperty -Path $WinstationsKey -Name 'UdpPortNumber' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 3390 -Force -Verbose
                New-NetFirewallRule -DisplayName 'Remote Desktop - Shortpath (UDP-In)'  -Action Allow -Description 'Inbound rule for the Remote Desktop service to allow RDP traffic. [UDP 3390]' -Group '@FirewallAPI.dll,-28752' -Name 'RemoteDesktop-UserMode-In-Shortpath-UDP'  -PolicyStore PersistentStore -Profile Domain, Private -Service TermService -Protocol udp -LocalPort 3390 -Program '%SystemRoot%\system32\svchost.exe' -Enabled:True -Verbose
            if (Test-Path $WinstationsKey\$fUseUdpPortRedirector -Verbose) {
        write-host "fUseUdpPortRedirector regkey has been created"
    }
    else {
        write-host "Error creating RDP Shortpath regkeys"
    }
  }
catch {
    $ErrorMessage = $_.Exception.message
    write-host "Error creating RDP Shortpath regkeys $ErrorMessage"
}
#endregion
#region AppxOverride
#Create Appx Override to improve login time for available Appx packages
$appname="Appxoverride"
try {
    $Arguments = @(
    "IMPORT"
    "$TempPath\AVDBuild\AppxOverride.reg"
    )
    Start-Process -filepath "reg.exe" -Wait -ErrorAction Stop -ArgumentList $Arguments -Verbose
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\OverrideConfig" -Verbose) {
        write-host "$appname has been installed"
    }
    else {
        write-host "Error installing $appname"
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-host "Error installing $appname Host $ErrorMessage"
}
#endregion
#region Citrix Optimizer
$appname="Citrix Optimizer"
Expand-Archive "$TempPath\avdbuild\CitrixOptimizer.zip" -DestinationPath "$TempPath\avdbuild\CitrixOptimizer"
$XML="$TempPath\avdbuild\CitrixOptimizer\W10-21H2.XML"
$RollbackXML="$LogPath\Rollback-W10-21H2.xml"
try {
    invoke-expression "$TempPath\avdbuild\CitrixOptimizer\CtxOptimizerEngine.ps1 -Source $XML -Mode Execute -OutputXml $RollbackXML" -Verbose
    if (Test-Path $RollbackXML -Verbose) {
        write-host "$appname has been installed"
    }
    else {
        write-host "Error installing $appname"
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-host "Error installing $appname Host $ErrorMessage"
}
#endregion
#region remove ActiveSetup
#clear windows Active Setup to improve login times of the WVD session
try {
$RegPath='HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\*'
Remove-Item -Path $RegPath -Recurse -Force
$RegPath = $RegPath.Substring(0,$RegPath.Length-1)
$items=Get-ChildItem -Path $RegPath 
$items.count

if ($items.count -eq 0) {
        write-host "Active Setup Cleared"
    }
    else {
        write-host "Error clearing Active Setup"
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-host "Error clearing Active Setup: $ErrorMessage"
}

try {
$RegPath64='HKLM:\SOFTWARE\WOW6432Node\Microsoft\Active Setup\Installed Components\*'
Remove-Item -Path $RegPath64 -Recurse -Force
$RegPath64 = $RegPath64.Substring(0,$RegPath64.Length-1)
$items=Get-ChildItem -Path $RegPath64
$items.count

if ($items.count -eq 0) {
        write-host "Active Setup WOW6432Node Cleared"
    }
    else {
        write-host "Error clearing Active Setup WOW6432Node"
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-host "Error clearing Active Setup WOW6432Node: $ErrorMessage"
}
#endregion
#region Enable-PSRemoting
try {
Enable-PSRemoting -Force -SkipNetworkProfileCheck -Verbose
write-host "Enabled PSRemoting" }
catch {
    $ErrorMessage = $_.Exception.message
    write-host "Error enabling PSRemoting $ErrorMessage"
}
#endregion
#region Cleanup
try {
        Get-ChildItem $TempPath -Recurse | Remove-Item -Force -Recurse -Verbose
        write-host "Cleanup of Temp storage"
}
catch {
    $ErrorMessage = $_.Exception.message
    write-host "Error Cleanup of temp $appname $ErrorMessage"
}
#endregion
#region FSLogix Exclusion
Get-LocalGroup 'administrators' | Add-LocalGroupMember -Name 'FSLogix Profile Exclude List'
#endregion
