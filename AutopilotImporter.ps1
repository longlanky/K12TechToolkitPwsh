Write-Host "Checking for requisite modules, please wait."
If ($null -eq $(Get-InstalledModule "WindowsAutoPilotIntune" -ErrorAction SilentlyContinue)) { Write-Host "WindowsAutoPilotIntune module not present."; Install-Module "WindowsAutoPilotIntune" }
If ($null -eq $(Get-InstalledModule AzureAD -ErrorAction SilentlyContinue) -and $null -eq $(Get-InstalledModule AzureADPreview -ErrorAction SilentlyContinue)) { Write-Host "AzureAD or AzureADPreview module not found."; Install-Module "AzureAD" }
Do { $CsvToImport = Read-Host -Prompt "Enter full location for CSV to import" } While ($null -eq $CsvToImport -or $CsvToImport -notmatch ".csv")

Do { $SinglePlural = Read-Host -Prompt "Enter '1' if importing only 1 HWID (this will not return success or failure), otherwise enter 'more',`nIf looking to check for error return for single hash, select 'more'." } While ($null -eq $SinglePlural -and $SinglePlural -notmatch "1" -and $SinglePlural -notmatch "more")
Do { $GroupTagIndicator = Read-Host -Prompt "Set group as 'Standard User Driven'(sud), 'Self Deploying'(slf), or 'Administrative User Driven'(aud)" } While ($GroupTagIndicator -notmatch "sud" -and $GroupTagIndicator -notmatch "slf" -and $GroupTagIndicator -notmatch "aud")
Switch ($GroupTagIndicator) {
    'sud' { $GroupTag = "Standard User Driven" }
    'slf' { $GroupTag = "Self Deploying" }
    'aud' { $GroupTag = "Administrative User Driven" }
}
Function SingleHash {
    $SerialNumber = Import-Csv $CsvToImport | Select-Object -Unique 'Device Serial Number' | Select-Object -ExpandProperty 'Device Serial Number'
    $HWIdentifier = Import-Csv $CsvToImport | Select-Object -Unique 'Hardware Hash' | Select-Object -ExpandProperty 'Hardware Hash'
    if ($(Import-Csv $CsvToImport | Measure-Object -Property "Device Serial Number" | Select-Object -ExpandProperty Count) -gt 1) { Write-Host "Too many devices, use 'more' option to import this"; Break }
    Write-Host "Connecting to MSGraph"
    Connect-MSGraph
    Write-Host "Importing $SerialNumber as $GroupTag device"
    Add-AutoPilotImportedDevice -serialNumber "$SerialNumber" -hardwareIdentifier "$HWIdentifier" -GroupTag "$GroupTag"
    Write-Host "Work finished, it may take a few minutes for the device to appear in the Autopilot"
}
Function ManyHashes {
    Write-Host "Connecting to MSGraph"
    Connect-MSGraph
    Write-Host "Importing CSV, all devices will be assigned as $GroupTag devices... This may take a while"
    Import-AutopilotCSV -csvFile "$CsvToImport" -groupTag "$GroupTag"
    Write-Host "Work finished, it may take a few minutes for the device to appear in the Autopilot"
}

Switch ($SinglePlural) {
    '1' { SingleHash }
    'more' { ManyHashes }
}
