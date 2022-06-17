#Determined Battery Shutoff script 23.05.22
#Intended for use with removable media

#Battery presence check
$batt_present = Get-CimInstance -ClassName Win32_Battery | Select-Object -ExpandProperty Status
if ($batt_present -ne "OK") {
    $eixet = Read-Host -Prompt 'Battery not detected, (e)xit, or (p)roceed?'
if ($eixet -eq "e") {
Write-Host "Exiting" -ForegroundColor Red
Start-Sleep 0.5
Break }
elseif ($eixet -eq "p") { Write-Host "Proceeding" -ForegroundColor Green}
else {Write-Host "Input not understood, exiting"; start-sleep 1; break}
}

#Check if in OOBE to determine if needs to be kept awake.
$ExplorerProcesses = @(Get-CimInstance -ClassName 'Win32_Process' -Filter "Name like 'explorer.exe'" -ErrorAction 'Ignore')
foreach ($TargetProcess in $ExplorerProcesses) { $Username = (Invoke-CimMethod -InputObject $TargetProcess -MethodName GetOwner).User}
if ($UserName -ne 'defaultuser0') {
    $NoSleep = '(New-Object -ComObject wscript.shell).SendKeys({+{F15}})'
} Else {$NoSleep = $null}

#Pull initial reading on battery level and prompt user for later decisions.
$batper = Get-CimInstance -ClassName Win32_Battery | Select-Object -ExpandProperty EstimatedChargeRemaining
$title = "Battery Drain-O-Matic"
$question = 'Shutdown or reboot at determined level?'
$choices = '&Shutdown', '&Reboot'
Write-Output "Battery: $batper%"
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {
$rors = "shutdown"
}
else {
$rors = "reboot"
}

Do { Try { $Error.Clear(); $limit = $null; $prompt = $null ; $prompt = (Read-Host -Prompt 'Battery level to prompt shutdown as integer, between 1 and 99, eg. "55", or "70"') ; If ($prompt -like "a number") { Write-Host "Very clever..." } ; $limit = [int]$prompt  } Catch { Write-Host "Please enter a number." } ; if ((1..99 -notcontains $limit) -and ($null -notmatch $limit)) { Write-Host "Number out of bounds." } } While (($error.count -gt 0) -or (1..99 -notcontains $limit))

do {
$batper = Get-CimInstance -ClassName Win32_Battery | Select-Object -ExpandProperty EstimatedChargeRemaining
$battery = Get-WmiObject -Class Win32_Battery | Select-Object -First 1
$noAC = $null -ne $battery -and $battery.BatteryStatus -eq 1    
$BattTimeRemaining = Get-CimInstance -ClassName Win32_Battery | Measure-Object -Property EstimatedRunTime -Average | Select-Object -ExpandProperty Average
if ($BattTimeRemaining -eq 71582788) {$TimeToTarget = "Forever"}
if ($BattTimeRemaining -eq 71582788 -and $noAC -match "True") {$TimeToTarget = "Calculating, please wait for refresh."}
if ($BattTimeRemaining -ne 71582788) {$TimeToTarget = New-Timespan -minutes ((($BatPer-$limit)/$BatPer)*$BattTimeRemaining)} 
Try {Invoke-Expression -Command $NoSleep} Catch {$null}


Clear-Host
    "Current charge: $batper%"
    "Battery target %: $limit%"
    "Est. time to $rors`: $TimeToTarget"
    if ($noAC) {Write-Host 'Battery discharging' -ForegroundColor green}
    else {Write-Host 'Connected to AC'-ForegroundColor red}

if ($batper -le $limit)
{ 
if ($rors -eq "shutdown") {shutdown /s /t 0}
if ($rors -eq "reboot") {shutdown /r /t 0}
}
Start-Sleep 5
}
while ($batper -ge $limit-2)
