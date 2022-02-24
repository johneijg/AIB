<#
Script purpose: Set Windows region & TimeZone to Dutch
Version: 1.0
Date: 18-01-2022
Author: John Eijgensteijn
Change log: First release
#>

#region Variables
$TempPath="c:\Temp\Software"
$LogPath="C:\Programdata\PPC\"
$Logfile="Software_Install.log"

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
#region Download Language Pack ISO's
#Current ISO Files can be found at;
#https://docs.microsoft.com/en-us/azure/virtual-desktop/language-packs
#Language ISO
$LangISO="https://software-download.microsoft.com/download/pr/19041.1.191206-1406.vb_release_CLIENTLANGPACKDVD_OEM_MULTI.iso"
#FOD Disk 1 ISO
$FodISO="https://software-download.microsoft.com/download/pr/19041.1.191206-1406.vb_release_amd64fre_FOD-PACKAGES_OEM_PT1_amd64fre_MULTI.iso"
#Inbox Apps ISO
$InboxISO="https://software-download.microsoft.com/download/sg/19041.928.210407-2138.vb_release_svc_prod1_amd64fre_InboxApps.iso"

write-host "Start downloading Language Pack ISOs"
try {
    $Output=$TempPath+"\Language.ISO"
    (New-Object System.Net.WebClient).DownloadFile($LangISO, $Output)
    #Allow time for OS to release access to file on disk
    Start-Sleep -Seconds 5
    if (Test-Path $Output) {
        write-host "$Output has been downloaded"
    }
    else {
        write-host "Error locating $Output" }
    }
catch {
    $ErrorMessage = $_.Exception.message
    write-host "Error Downloading $Output $ErrorMessage"
}

write-host "Start downloading Feature On Demand ISO"
try {
    $Output=$TempPath+"\Fod.ISO"
    (New-Object System.Net.WebClient).DownloadFile($FodISO, $Output)
    #Allow time for OS to release access to file on disk
    Start-Sleep -Seconds 5
   if (Test-Path $Output) {
        write-host "$Output has been downloaded"
    }
    else {
        write-host "Error locating $Output" }
    }
catch {
    $ErrorMessage = $_.Exception.message
    write-host "Error Downloading $Output $ErrorMessage"
}

write-host "Start downloading InboxApp ISOs"
try {
    $Output=$TempPath+"\Inbox.ISO"
    (New-Object System.Net.WebClient).DownloadFile($InboxISO, $Output)
    #Allow time for OS to release access to file on disk
    Start-Sleep -Seconds 5    
    if (Test-Path $Output) {
        write-host "$Output has been downloaded"
    }
    else {
        write-host "Error locating $Output" }
    }
catch {
    $ErrorMessage = $_.Exception.message
    write-host "Error Downloading $Output $ErrorMessage"
}
write-host "Finished downloading Language Pack ISOs"
#endregion
#region Install Dutch LanguagePack

try {
write-host "Extract ISO content for Language Pack installation"
        $ISOs=Get-ChildItem -Filter *.iso $TempPath
        Foreach ($ISO in $ISOs) {
            #mount ISO with Y: drive mapping
            $driveLetter = "Y:"
            $diskImg = Mount-DiskImage -ImagePath $ISO.fullname -NoDriveLetter
            $volInfo = $diskImg | Get-Volume
            mountvol $driveLetter $volInfo.UniqueId
            #files not to copy
                $exclude = @("winpe*", "*x86*", "*arm64*")
                #copy relevant files
                get-childitem y:\ -Filter License.xml -Recurse | copy-Item -Destination $LanguagePath -ErrorAction Ignore
                get-childitem y:\*nl-nl* -Exclude $exclude -Recurse | copy-Item -Destination $LanguagePath -ErrorAction Ignore
                    if (test-path y:\amd64fre -ErrorAction Ignore) {
                        get-childitem y:\amd64fre\ -Recurse | copy-Item -Destination $LanguagePath -ErrorAction Ignore} 
                        start-sleep -Seconds 5

             DisMount-DiskImage -ImagePath $ISO.fullname }
            
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Output "Copying Language files $ErrorMessage"
}
write-host "Finished ISO content for Language Pack installation"


########################################################
## Add Languages to running Windows Image for Capture ##
########################################################
write-host "Start  Language Pack installation"
##Disable Language Pack Cleanup##
Disable-ScheduledTask -TaskPath "\Microsoft\Windows\AppxDeploymentClient\" -TaskName "Pre-staged app cleanup" -Verbose
 
##Set Language Pack Content Stores##
[string]$LIPContent = $TempPath+"\NL"
 
##Dutch##
Add-AppProvisionedPackage -Online -PackagePath $LIPContent\LanguageExperiencePack.nl-nl.Neutral.appx -LicensePath $LIPContent\License.xml -Verbose

$WindowsPackages=get-childitem $LanguagePath -Filter *.cab 
Foreach ($Package in $WindowsPackages) {
Add-WindowsPackage -Online -PackagePath $Package.fullname -ErrorAction Ignore -Verbose
}

$LanguageList = Get-WinUserLanguageList
$LanguageList.Add("nl-nl")
Set-WinUserLanguageList $LanguageList -force -Verbose
write-host "Finished  Language Pack installation"
#########################################
## Update Inbox Apps for Multi Language##
#########################################
##Set Inbox App Package Content Stores##
write-host "Start update Inbox apps"
[string]$InboxApps = $TempPath+"\NL"
##Update Inbox Store Apps##
$AllAppx = Get-Item $inboxapps\*.appx | Select-Object name
$AllAppxBundles = Get-Item $inboxapps\*.appxbundle | Select-Object name
$allAppxXML = Get-Item $inboxapps\*.xml | Select-Object name
foreach ($Appx in $AllAppx) {
    $appname = $appx.name.substring(0,$Appx.name.length-5)
    $appnamexml = $appname + ".xml"
    $TempPathappx = $InboxApps + "\" + $appx.Name
    $TempPathxml = $InboxApps + "\" + $appnamexml
    
    if($allAppxXML.name.Contains($appnamexml)){
    
    Write-Host "Handeling with xml $appname"  
  
    Add-AppxProvisionedPackage -Online -PackagePath $TempPathappx -LicensePath $TempPathxml -ErrorAction Ignore -Verbose
    } else {
      
      Write-Host "Handeling without xml $appname"
      
      Add-AppxProvisionedPackage -Online -PackagePath $TempPathappx -skiplicense -ErrorAction Ignore -Verbose
    }
}
foreach ($Appx in $AllAppxBundles) {
    $appname = $appx.name.substring(0,$Appx.name.length-11)
    $appnamexml = $appname + ".xml"
    $TempPathappx = $InboxApps + "\" + $appx.Name
    $TempPathxml = $InboxApps + "\" + $appnamexml
    
    if($allAppxXML.name.Contains($appnamexml)){
    Write-Host "Handeling with xml $appname"
    
    Add-AppxProvisionedPackage -Online -PackagePath $TempPathappx -LicensePath $TempPathxml -ErrorAction Ignore -Verbose
    } else {
       Write-Host "Handeling without xml $appname"
      Add-AppxProvisionedPackage -Online -PackagePath $TempPathappx -skiplicense -ErrorAction Ignore -Verbose
    }
}
write-host "Finished update of Inbox apps"
#endregion
