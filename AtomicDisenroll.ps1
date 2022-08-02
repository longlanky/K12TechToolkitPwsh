        Clear-Host
        Write-Host "Checking for requisite modules, please wait" -ForegroundColor Yellow
        If ($null -eq $(Get-InstalledModule "WindowsAutoPilotIntune" -ErrorAction SilentlyContinue)) { Write-Host "WindowsAutoPilotIntune module not present."; Install-Module "WindowsAutoPilotIntune" }
        If ($null -eq $(Get-InstalledModule "MSOnline" -ErrorAction SilentlyContinue)) { Write-Host "MSOnline module not present."; Install-Module "MSOnline" }
        Clear-Host
        Write-Host "Atomic Disenroller" -ForegroundColor Red
        Write-Host "Device serial number: ${Env:ComputerName}"
        $Serial = Read-Host -Prompt "Enter device serial number to disenroll, or enter 'EXIT' to leave script"
        if ($Serial -match "EXIT") { Break }
        Connect-MSGraph
        Connect-AzureAd
        Connect-MsolService
        $GAPD = (Get-AutopilotDevice -serial $Serial).id
        $GIMD = (Get-IntuneManagedDevice -Filter ("SerialNumber eq '$Serial'")).id
        $GAAD = (Get-AzureADDevice -Filter "startswith(Displayname,'$Serial')").DeviceId
        #Remove from Intune
        If ($GIMD) {Remove-DeviceManagement_ManagedDevices -managedDeviceId $GIMD; Write-Host "Removing device from Intune"} Else {Write-Host "Device $Serial not found in Intune"}
        #Remove from Azure Active Directory
        If ($GAAD) { Remove-MsolDevice -DeviceId $GAAD; Write-Host "Removing device from Azure AD"} Else { Write-Host "Device $Serial not found in AAD" }
        #Remove from Autopilot
        If ($GAPD) {Remove-AutopilotDevice -id $GAPD; Write-Host "Removing device from Autopilot"} Else {Write-Host "Device $Serial not found in Autopilot"}
