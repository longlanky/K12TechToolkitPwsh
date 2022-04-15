#Nolan's Determined Battery Shutoff script v1.0 07042022
#Intended for use with removable media
#Ensure Caffeine64.exe is present in directory with this script
#Quick and dirty script to keep device awake, then shutdown or reboot when battery level reaches predetermined percentage 

#Battery presence check
$batt_present = Get-CimInstance -ClassName Win32_Battery | Select-Object -ExpandProperty Status
if ($batt_present -ne "OK") {
    $eixet = Read-Host -Prompt 'Battery not detected, (e)xit, or (p)roceed?'
if ($eixet -eq "e") {
Write-Host "Exiting" -ForegroundColor Red
Start-Sleep 0.5
Exit }
else {
    Write-Host "Proceeding" -ForegroundColor Green
}
}

#Check if in OOBE, if not in OOBE, check for an existing installation of Caffeine, if not present, install, then run, otherwise, run Caffeine.
#(Keep the device from going to sleep)
$ExplorerProcesses = @(Get-CimInstance -ClassName 'Win32_Process' -Filter "Name like 'explorer.exe'" -ErrorAction 'Ignore')
foreach ($TargetProcess in $ExplorerProcesses) { $Username = (Invoke-CimMethod -InputObject $TargetProcess -MethodName GetOwner).User}
if ($UserName -ne 'defaultuser0') {
    Write-Host "Not in OOBE, pouring a cup of joe." -ForegroundColor Green
    $cupofcoffee = Test-Path -Path "C:\Program Files\Caffeine\caffeine64.exe" -Pathtype Leaf
    $location = Get-Location
    $2muchcafe = (Get-CimInstance -ClassName 'Win32_Process' -Filter "Name like 'caffeine64.exe'" -ErrorAction 'Ignore')
    if ($null -eq $2muchcafe){
    if ($cupofcoffee -ne "True") {
        New-Item -Path "C:\Program Files\" -Name "Caffeine" -ItemType "directory"
        Copy-Item "$location\caffeine64.exe" -Destination "C:\Program Files\Caffeine\"
        ."C:\Program Files\Caffeine\caffeine64.exe"
    }
    else {
        ."C:\Program Files\Caffeine\caffeine64.exe"
    } }
    If ($null -ne $2muchcafe) {Write-Host "Already caffeinated!" -ForegroundColor DarkYellow}
}
else {
    Write-Host "In OOBE, will remain uncaffeinated." -ForegroundColor Red
}
#Pull initial reading on battery level and prompt user for later decisions.
$batper = Get-CimInstance -ClassName Win32_Battery | Select-Object -ExpandProperty EstimatedChargeRemaining
$title = "Nolan's Battery Drain-O-Matic"
$question = 'Shutdown or reboot @ determined level?'
$choices = '&Shutdown', '&Reboot'
Write-Output "Battery: $batper%"
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {
$rors = "Shutdown"
}
else {
$rors = "Reboot"
}

$limit = Read-Host -Prompt 'Battery level to prompt shutdown as integer, eg. "55", or "70"'

#Check for non-integer answer and give error:
#$integral = $limit -is [int]

#while ($limit -le "-1" -or $limit -ge "100" -or $integral -ne "True") {
#    $limit = Read-Host -Prompt 'Input out of bounds, please write a value between 0 & 99.'
#    $integral = $limit -is [int] 
#}


do {

    $batper = Get-CimInstance -ClassName Win32_Battery | Select-Object -ExpandProperty EstimatedChargeRemaining
    #$limit = 55
    #DateLimit variable: Set day for script to stop working, formatted as: Year, eg. "2022", followed by the day in the year, eg. "252"
    #The purpose of this parameter is to prevent the script from running past a predetermined date if launched automatically.
    #This is off by default, see graveyard code below for how to enable.
    $DateLimit = 2022252
    $DayofYear = (Get-Date).Dayofyear
    $year = Get-Date -UFormat %Y
    $ydoy = $year + $dayofyear
    #Check if connected to charger
    $battery = Get-WmiObject -Class Win32_Battery | Select-Object -First 1
    $noAC = $null -ne $battery -and $battery.BatteryStatus -eq 1 
    
$BattTimeRemaining = Get-CimInstance -ClassName Win32_Battery | Measure-Object -Property EstimatedRunTime -Average | Select-Object -ExpandProperty Average
if ($BattTimeRemaining -eq 71582788) {$TimeToTarget = "Forever"}
else {$TimeToTarget = New-Timespan -minutes ((($BatPer-$limit)/$BatPer)*$BattTimeRemaining)} 

    
Clear-Host

    "Current charge: $batper"
    "Battery limit %: $limit"
    "Date to stop: $DateLimit"
    "Current DayofYear: $dayofyear"
    "Current Year: $year"
    "YDOY variable: $ydoy"
    "Est. time to discharge: $TimeToTarget"
    if ($noAC) {
        Write-Host 'Battery discharging' -ForegroundColor green
    }
    else {
        Write-Host 'Connected to AC'-ForegroundColor red

    }

#Turn off device if battery is at less than or equal to set value (default 55%)
# Graveyard code :  -and ($ydoy -le $datelimit))
if ($batper -le $limit)
{ 
if ($rors -eq "Shutdown") {
shutdown /s /t 0
}
if ($rors -eq "Reboot") {
shutdown /r /t 0
}

}

Start-Sleep 30

}

while ($batper -ge $limit-2)
