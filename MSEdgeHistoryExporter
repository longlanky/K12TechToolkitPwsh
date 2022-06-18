Write-Host "Checking for requisite module, this may take a while."
$Error.clear()
$ModuleState = Get-InstalledModule -Name "PSSQLite" -ErrorAction SilentlyContinue
If ($null -eq $ModuleState -and ($error.count) -gt 0) {
    $InstQuery = Read-Host -Prompt "PSSQLite module not installed. Press 'I' enter to install, or press enter to exit."
    If ($InstQuery -match "I") { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force; Set-PSRepository PSGallery -InstallationPolicy Trusted; Install-Module PSSQLite -Repository PSGallery }
    Else { Break } 
}
$LocalUsers = Get-ChildItem "C:\Users\" | Select-Object -ExpandProperty Name
foreach ($name in $LocalUsers) {
    If (Test-Path -Path "C:\Users\$name\AppData\Local\Microsoft\Edge\User Data\Default\history" -PathType Leaf) { $Names = $Names + "$name " }
}
if ($Null -eq $Names) { Write-Host "No users with Edge history found!"; Break }
Write-Host "History found for following users:`n$Names`r"
$SelectedUser = Read-Host -Prompt "Enter username to export MS Edge history, or leave blank to export current user ($env:UserName)"
If ($null -match $SelectedUser) { $SelectedUser = $env:UserName }
$SanityCheck = Test-Path -Path "C:\Users\$SelectedUser\AppData\Local\Microsoft\Edge\User Data\Default\history" -PathType Leaf
If (($env:UserName) -notmatch $SelectedUser -and $SanityCheck -match "True") { Write-Host "Exporting $SelectedUser's history to Downloads folder" }
Elseif (($env:UserName) -match $SelectedUser -and $SanityCheck -match "True") { 
    if ($null -ne $(Get-Process | Where-Object { $_.ProcessName -Like "*msedge" })) {
        $CloseEdge = Read-Host -Prompt "Please ensure that Edge is closed, or export may not generate, press enter to close Edge, or any key to continue."
        If ($null -match $CloseEdge) { Write-Host "Closing Edge"; Get-Process | Where-Object { $_.ProcessName -Like "*msedge*" } | Stop-Process }
        Else { Write-Host "Proceeding" }
    }
    Write-Host "Exporting current user's Edge History to Downloads folder"
}
Elseif ($SanityCheck -match "False") { Write-Host "User history not found, account either not present or history is absent. Exiting."; Break }
$ExitCheck = "C:\Users\$env:UserName\Downloads\MSEdge_History_$SelectedUser`_$(Get-Date -Format "HHmm_MMddyy").csv"
Invoke-SqliteQuery -Query "SELECT url,title,visit_count,last_visit_time FROM urls" -DataSource "C:\Users\$SelectedUser\AppData\Local\Microsoft\Edge\User Data\Default\history" | Sort-Object last_visit_time -Descending | Select-Object *, @{ Name = 'date_last_accessed'; Expression = { '=TEXT(INDIRECT("D"&ROW())*(1.15740740740741E-11)-(109205.1665),"mm.dd.yyyy HH:mm AM/PM")' } } | Export-Csv -Path "C:\Users\$env:UserName\Downloads\MSEdge_History_$SelectedUser`_$(Get-Date -Format "HHmm_MMddyy").csv"
If ((Get-Item $ExitCheck).length -lt 1kb) { If ($SelectedUser -match $env:UserName) { Write-Host "Report did not generate, ensure that Edge is closed and retry" } Else { Write-Host "Report did not generate, history may not be present for $SelectedUser." } } 
