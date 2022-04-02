# K12TechToolkitPwsh
Personal repository of powershell scripts used in servicing Windows devices in K-12 school. 
This is something I put together in my free time while working in the capacity of a technician to save time.

The scripts included here I have found to be helpful in servicing Windows devices, especially during initial imaging & setup process.
BIOS and TPM updating scripts are intended specifically for servicing Dell devices for my particular case and device fleet, although they can be easily modified to work on essentially any Dell device.

Primary features of primary toolkit script is to reference other scripts and display helpful diagnostics, including:
-Current battery health as reported actual capacity/ design capacity
-Space free in C:\ drive
-Secure boot state
-Windows build number
-BIOS revision & indication of update availability (Dell)
-Serial number
-Administrative privilege check
-Winget presence and version

Scripts that can be invoked from this menu include:
-BIOS updater (Dell)
-TPM update (Dell) & management 
-Disk management
-Microsoft Teams management (installation, removal, update, web scraper)
-MDM Diagnostics tool generation
-AzureAD password reset 
-Autopilot hardware hash generation and decoding for diagnostics
-Battery health, including...
-Battery discharge to predetermined percentage of total charge
-Battery health report
among others

Hopeful future features:
-Automatic web scraping for Dell BIOS updates
-Internet status indicator
