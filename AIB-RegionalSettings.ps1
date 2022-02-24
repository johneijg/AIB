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

#region Timezone and Keyboard
try {
write-host "Setting Timesettings and regional settings"
#variables
$RegionalSettings = $TempPath+"\AVDBuild\DutchRegionalSettings.xml"

# Set Locale, language etc. 
& $env:SystemRoot\System32\control.exe "intl.cpl,,/f:`"$RegionalSettings`""

# Set languages/culture. Not needed perse.
Set-TimeZone -id "W. Europe Standard Time" -Verbose
Set-WinSystemLocale nl-NL -Verbose
Set-WinUserLanguageList -LanguageList nl-NL -Force -Verbose
Set-Culture -CultureInfo nl-NL -Verbose
Set-WinHomeLocation -GeoId 176 -Verbose
}
catch {
    $ErrorMessage = $_.Exception.message
    write-host "Error setting Timesettings $ErrorMessage"
}

#endregion
