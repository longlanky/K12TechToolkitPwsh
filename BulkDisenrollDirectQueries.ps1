    Clear-Host
        Write-Host "Checking for requisite modules, please wait" -ForegroundColor Yellow
        If ($null -eq $(Get-InstalledModule "WindowsAutoPilotIntune" -ErrorAction SilentlyContinue)) { Write-Host "WindowsAutoPilotIntune module not present."; Install-Module "WindowsAutoPilotIntune" }
        If ($null -eq $(Get-InstalledModule "MSOnline" -ErrorAction SilentlyContinue)) { Write-Host "MSOnline module not present."; Install-Module "MSOnline" }
        Clear-Host
        Write-Host "Batch Disenroller" -ForegroundColor Red
        $CsvFile = Read-Host -Prompt "Enter Csv file containing DeviceIDs, or enter 'EXIT' to leave script`n"
        if ($Serial -match "EXIT") { Break }
        Connect-MSGraph
        Connect-AzureAd
        Connect-MsolService
        Import-Csv "$CsvFile" -Header 'DeviceID' | ForEach-Object {
            $Serial = $($_.DeviceID)
            $GAPD = (Get-AutopilotDevice -serial $Serial).id
            $GIMD = (Get-IntuneManagedDevice -Filter ("SerialNumber eq '$Serial'")).id
            $GAAD = (Get-AzureADDevice -Filter "startswith(Displayname,'$Serial')").DeviceId
                Write-Host "$Serial"
                if ($GIMD){
                #Remove from Intune
                Remove-DeviceManagement_ManagedDevices -managedDeviceId $GIMD
                Write-Host "$GIMD"}
                if ($GAAD){
                #Remove from Azure Active Directory
                Write-Host "$GAAD"
                Remove-MsolDevice -DeviceId $GAAD}
                if ($GAPD) {
                #Remove from Autopilot
                Write-Host "$GAPD"
                Remove-AutopilotDevice -id $GAPD}
                If ($GAPD -and $GIMD -and $GAAD) {$ALLout += "$Serial "} Else{
                If ($GAPD) {$APout += "$Serial "}
                If ($GIMD) {$INout += "$Serial "}
                If ($GAAD) {$AADout += "$Serial "}}
             }
            if ($APout -or $INout -or $AADout) {
                Write-Host "`n"
                If ($ALLout){
                    Write-Host "Successfully removed objects from Autopilot, Intune and Azure Active Directory for the following devices:`n"
                    Write-Host "$Allout"}
                if ($APout) {
                    Write-Host "Successfully removed objects from " -NoNewline; Write-Host "Autopilot" -ForegroundColor Yellow -NoNewline; Write-Host " for the following device:`n" -NoNewline
                    Write-Host "$APout"
                }
                if ($INout) {
                    Write-Host "Successfully removed objects from" -NoNewline;Write-Host " Intune" -ForegroundColor Yellow -NoNewline; Write-Host " for the following device:`n"
                    Write-Host "$INout"
                }
                if ($AADout) {
                   Write-Host "Successfully removed objects from" -NoNewline; Write-Host " Azure Active Directory" -ForegroundColor Yellow -NoNewline; Write-Host " for the following device:`n"
                   Write-Host "$AADout" 
                }
            }
            Else {Write-Host "No devices found in Autopilot to disenroll" -Foregroundcolor Red}