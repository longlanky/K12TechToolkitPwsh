#Set BIOS password manually below!
#Assumes Dell firmware updaters in same directory as script
#Ensure version string and model number is shown in update file
#Not neccessary, but updater executable name can be simplified to VersionNumber_ModelNumber.exe
#eg. 3120_1.7.0.exe

#Variable declarations and initializations
$CurrentFWVersion = Get-WmiObject -ClassName "Win32_BIOS" | Select-Object -ExpandProperty "Name"
$Model = Get-WmiObject -ClassName "Win32_ComputerSystem" | Select-Object -ExpandProperty "Model"
$source = "$PSScriptRoot"
$Destination = Split-Path -Path $source -Parent
$UpdatePath = "$Destination\Updates"
$ManuMaker = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer
if ($ManuMaker -ne "Dell Inc.") {Write-Host "Manufacturer not supported, exiting." -ForegroundColor Red; Exit}

#Get the update file name using the model retrieved from WMI
switch ($Model) {
    "Latitude 3120" { $UpdateFile = Get-ChildItem -Path "$UpdatePath" -Recurse -Filter '*3120*' | Select-Object -ExpandProperty "Name" }
    "Latitude 3189" { $UpdateFile = Get-ChildItem -Path "$UpdatePath" -Recurse -Filter '*3189*' | Select-Object -ExpandProperty "Name" }
    "Latitude 3190 2-in-1" { $UpdateFile = Get-ChildItem -Path "$UpdatePath" -Recurse -Filter '*3190*' | Select-Object -ExpandProperty "Name" }
    "Latitude 7320 Detachable" { $UpdateFile = Get-ChildItem -Path "$UpdatePath" -Recurse -Filter '*7320*' | Select-Object -ExpandProperty "Name" }
    "Latitude 7320" { $UpdateFile = Get-ChildItem -Path "$UpdatePath" -Recurse -Filter '*7X20*' | Select-Object -ExpandProperty "Name" }
    "Latitude 7210 2-in-1" { $UpdateFile = Get-ChildItem -Path "$UpdatePath" -Recurse -Filter '*7210*' | Select-Object -ExpandProperty "Name" }
    "Optiplex 7440 AIO" { $UpdateFile = Get-ChildItem -Path "$UpdatePath" -Recurse -Filter '*7440*' | Select-Object -ExpandProperty "Name" }
    "Optiplex 7450 AIO" { $UpdateFile = Get-ChildItem -Path "$UpdatePath" -Recurse -Filter '*7450*' | Select-Object -ExpandProperty "Name" }
    "Optiplex 7460 AIO" { $UpdateFile = Get-ChildItem -Path "$UpdatePath" -Recurse -Filter '*7460*' | Select-Object -ExpandProperty "Name" }
    "Optiplex 7470 AIO" { $UpdateFile = Get-ChildItem -Path "$UpdatePath" -Recurse -Filter '*7470*' | Select-Object -ExpandProperty "Name" }
    "Optiplex 7770 AIO" { $UpdateFile = Get-ChildItem -Path "$UpdatePath" -Recurse -Filter '*7770*' | Select-Object -ExpandProperty "Name" }
    "Optiplex 9030 AIO" { $UpdateFile = Get-ChildItem -Path "$UpdatePath" -Recurse -Filter '*9030*' | Select-Object -ExpandProperty "Name" }
}

If ($null -eq $UpdateFile) {Write-Host "Update file not present, exiting."; exit}

$PendingUpdate = (Select-String -InputObject "$UpdateFile" -Pattern '([0-9]+(\.[0-9]+)+)' -AllMatches).Matches | Foreach-Object { $_.Groups[1].Value }
if ([System.Version]($PendingUpdate) -gt [System.Version]($CurrentFWVersion)) {
#Execute the firmware update
Write-Host "Updating from $CurrentFWVersion to $pendingupdate."
Start-Process -FilePath "$UpdatePath\$UpdateFile" -ArgumentList "/s /r /forceit /p=BIOSPASSWORDHERE" -NoNewWindow -Wait
#Remove arguments /s /r /forceit for debugging purposes, replace if not present before production    
}
else {
Write-Host "Newer update not present."
Start-Sleep 2
Exit
}
