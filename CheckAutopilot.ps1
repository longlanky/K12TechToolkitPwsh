Clear-Host; Write-Host "Checking for requisite module, this may take a while..." -Foregroundcolor Yellow
If ($null -eq $(Get-InstalledModule "WindowsAutoPilotIntune" -ErrorAction SilentlyContinue)) { Write-Host "WindowsAutoPilotIntune module not present."; Install-Module "WindowsAutoPilotIntune" }
Clear-Host
Write-Host "This device's serial number: $((Get-WmiObject win32_bios).Serialnumber)"
$Serial = Read-Host -Prompt "Enter serial number to check Autopilot state"
Connect-MSGraph
Connect-AzureAd
$GAPD = Get-AutopilotDevice -serial $serial
$deviceID = (Get-AzureADDevice -Filter "startswith(Displayname,'$Serial')").ObjectId
if ($null -eq $GAPD) { Write-Host "Device not enrolled in Autopilot" -Foregroundcolor red; break }
Write-Host "---------------------------------------"
Write-Host "Device profile status:" -NoNewLine
switch (($GAPD).deploymentProfileAssignmentStatus) {
    'assignedUnkownSyncState' { Write-Host "Profile Assigned" -ForegroundColor Green }
    'pending' { Write-Host "Profile Pending" -ForegroundColor Yellow }
    'notassigned' { Write-Host "Profile Unassigned" -ForegroundColor Red }
    { $_ -notmatch 'assignedUnkownSyncState' -and $_ -notmatch 'pending' -and $_ -notmatch 'notassigned' } { Write-Host "Assignment failed" -Foregroundcolor red }
}
Write-Host "Group membership:" -NoNewLine; Write-Host "$(if($($GAPD).grouptag){"$(($GAPD).grouptag)"; $GPMC = @{ForegroundColor = "Yellow" }} Else {"No group selected!!" ; $GPMC = @{ForegroundColor = "Red" }})" @GPMC
Write-Host "Enrollment:" -NoNewLine
switch (($GAPD).enrollmentstate) {
    'notContacted' { Write-Host "Not contacted" -Foregroundcolor Red }
    'enrolled' { Write-Host "Enrolled" -Foregroundcolor Yellow }
}
Write-Host "Autopilot enrollment date: $((($GAPD).deploymentProfileAssignedDateTime).ToLocalTime()) $((get-timezone).id)"
Write-Host "Last contacted time:" -NoNewline
Switch (($GAPD).lastContactedDateTime) {
    '01/01/0001 00:00:00' { Write-Host "Not contacted" -ForegroundColor Red }
    { $_ -notmatch '01/01/0001 00:00:00' } { Write-Host "$(($_).ToLocalTime()) $((get-timezone).id)" }
}
Write-Host "Device model: $(($GAPD).model) "
Write-Host "Azure groups:"
Switch ($(((Invoke-MSGraphRequest -Url "/devices/$deviceID/memberOf").value).displayName)) {
    {$null -eq $_}{Write-Host "No Azure groups found." -ForeGroundColor Red}
    {$null -ne $_}{"$_"}
}
Write-Host "---------------------------------------`n"
Disconnect-AzureAd