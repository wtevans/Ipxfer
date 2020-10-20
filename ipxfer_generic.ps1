<#
.SYNOPSIS
Ipxfer Script

By: wtevans

This script is designed to run the Ipxfer to either move agents to another server or to update the current certificate if a mismatch is found.

.Description
For this script to function properly, you will need to place both of the ipxfer's (64 bit and 32 bit versions) along with the ofcntcert.dat file in the same running directory as this script. 

•	The Ipxfer.exe 32 bit and 64 bit versions are located in the Officescan/ApexOne on-prem server [Server Install Path]\PCCSRV\Admin\Utility\IpXfer. 
•	The ofcntcert.dat file is located in [Server Path]\PCCSRV\Pccnt\Common\OfcNTCer.dat. 

You must modify this script to specify the correct values specific to your environment. Open the script and navigate to the section called "Specified Variables" you will need to specify the following values:

$password = '******' replace with the unload password 
$http_port = 80 replace with the HTTP port of osce server
$https_port = 443 # replace with the HTTPS port of osce server
$listening_port = 21112 # replace with the agent listening port
$OSCE_server = "******.manage.trendmicro.com" # replace with the OSCE server name
$updateCertificate = $true # The two allowed values are $true and $false. If $false is selected the agent will not run Ipxfer if it is reporting to the correct server already. $true is recommended in most scenarios.


.NOTES 
- A utf8 log will be outputted in the executing users %temp% directory for reference of what occurred during the script’s execution.
- The update certificate option can be disabled to make the script only move agents if they are reporting to the wrong server if so desired. To modify this check the "Specified Variables" section of the script.
- If deployed with a deployment tool the ipxfer tools, ofcntcert.dat, and this script need to be in the same directory and run from that directory as well to function. 


.EXAMPLE
./ipxfer.ps1

.Link
Trend Micro KB's for ipxfer:
https://success.trendmicro.com/solution/0127004-manually-transferring-or-re-establishing-communication-between-officescan-apex-one-agents-and-server
https://success.trendmicro.com/solution/1102851-officescan-agents-do-not-have-a-valid-officescan-server-certificate-appears-on-the-dashboard
#>

###############################################################################
# Specified Variables
# For information on finding this info please see the KB links. 
$password = '******' # Place unload password here
$http_port = 80 # HTTP port of osce server
$https_port = 443 # HTTPS port of osce server
$listening_port = 21112 # Agent listening port
$OSCE_server = "******.manage.trendmicro.com" # Replace with osce server name
$updateCertificate = $true # The two allowed values are $true and $false. If $false is selected the agent will not run ipxfer if it is reporting to the correct server already. $true is recommended in most scenarios.  
###############################################################################


# System Variables
$64bit = [System.Environment]::Is64BitOperatingSystem
$Location = Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path

#Log Var's
$date = Get-Date -Format "MM-dd-hh-mm"
$Global:Filename = "Ipxfer.log" # Change this to the desired log name
$oldlog = "Ipxfer_$date.log" # Change this to the desired old log name
$Global:LogFilePath = "$env:TEMP\Ipxfer" # Change this to the desired path | Do not include trailing "\" as this would cause a syntax error

# Logging Function for UTF8 log
function UTF8Log {
    # Function by: Jeff Clark
    param (
        [Parameter(Mandatory=$true)]
        $message,
        [Parameter(Mandatory=$true)]
        $component,
        [Parameter(Mandatory=$true)]
        $type 
    )
    switch ($type){
        1 {$type = "Info"}
        2 {$type = "Warning"}
        3 {$type = "Error"}
    }
    if (($type -match "Info") -and ($Global:ScriptStatus -notmatch 'Error')) {
        $Global:ScriptStatus = $type
    } 
    if (($type -match "Warning") -and ($Global:ScriptStatus -notmatch 'Error')) {
        $Global:ScriptStatus = $type 
    }
    if (($type -match "Error")-and ($Global:ScriptStatus -notmatch 'Error')) { 
        $Global:ScriptStatus = $type 
    }
    $LogEntry = "{0} `$$<{1}><{2} {3}><thread={4}>" -f ($Type + ": " + $message), ($component), (Get-Date -Format "MM-dd-yyyy"), (Get-Date -Format "HH:mm:ss.ffffff"), $pid
    $LogEntry | Out-File -Append -Encoding UTF8 -FilePath ("$Global:LogFilePath\$Global:filename") 
}


# Creates the log files and folder
if(!(Test-path $Global:LogFilePath)){
    New-item -itemtype directory -path $Global:LogFilePath -Force | Out-Null   
}
if(Test-path $Global:LogFilePath\$Global:Filename){
    rename-item -path $Global:LogFilePath\$Global:Filename -NewName $oldlog -Force | Out-Null
}
if(!(Test-path $Global:LogFilePath)){
    New-item -itemtype directory -path $Global:LogFilePath -Force | Out-Null

} 
New-item -path $Global:LogFilePath -itemtype File -name $Global:Filename -Force| Out-Null

$Component = 'LogCreator'
UTF8Log -message "Logging Initialized." -type "1" -component "$Component"



###############################################################################

# Script Logic

$key = "HKLM:\SOFTWARE\WOW6432Node\TrendMicro\PC-cillinNTCorp\CurrentVersion"
$registeredServer = (Get-ItemProperty -Path $key -Name Server).Server
$Component = 'ipxferScript'

$ipxfer64 = Test-Path "$location\IpXfer_x64.exe"
$ipxfer86 = Test-Path "$location\IpXfer.exe"
$ofcntcert = Test-Path "$location\ofcntcer.dat"


# This section verifies that all the required files are present before continuing. The script will exit if not. 
if ($ipxfer64 -eq $false -or $ipxfer86 -eq $false -or $ofcntcert -eq $false){
    UTF8Log -message "Package is not set up properly, the issue is not with the script." -type "3" -component "$Component"
    UTF8Log -message "Please place the IpXfer's and ofcntcer.dat in the same location as the script." -type "3" -component "$Component"
    Write-Host "Package is not set up properly, the issue is not with the script." -ForegroundColor Red
    Write-Host "Please place the IpXfer's and ofcntcer.dat in the same location as the script and re-run the script." -ForegroundColor Red
    Start-Sleep 20
    exit 5
}

UTF8Log -message "Agent is reporting to $registeredServer" -type "1" -component "$Component"
UTF8Log -message "Agent needs to move to $OSCE_server" -type "1" -component "$Component"
Write-Host "Agent is reporting to $registeredServer" -ForegroundColor Yellow
Write-Host "Agent needs to move to $OSCE_server" -ForegroundColor Yellow

# Checks to see if the agent even needs to move. This section will not run if $updateCertificate at the top is set to $true 
If($updateCertificate -eq $false -and $registeredServer -eq $OSCE_server){
    Write-Host "Agent is already reporting to the correct server" -ForegroundColor Green
    UTF8Log -message "Agent is already reporting to the correct server" -type "1" -component "$Component"
    Start-Sleep 10
    exit 0
}

if($updateCertificate -eq $true -and $registeredServer -eq $OSCE_server){
    Write-Host "Proceeding to allow for agent certificate update" -ForegroundColor Yellow 
    UTF8Log -message "Proceeding to allow for agent certificate update" -type "1" -component "$Component"
}

# Runs the 32 bit ipxfer if the agent is determined  to be a 32 bit machine from the "System Variables" section at the top
If($64bit -eq $false){

    Write-host "32-Bit Machine detected" -ForegroundColor Yellow
    Write-Host "Moving agent to report to $OSCE_server" -ForegroundColor Yellow
    UTF8Log -message "32-Bit Machine detected" -type "1" -component "$Component"
    UTF8Log -message "Moving agent to report to $OSCE_server" -type "1" -component "$Component"
    & $location\IpXfer.exe -s $OSCE_server -p $http_port -sp $https_port -c $listening_port -e "$location\OfcNTCer.dat" -pwd "$password"
}

# Runs the 64 bit ipxfer if the agent is determined  to be a 64 bit machine from the "System Variables" section at the top
if($64bit -eq $true){

    Write-host "64-Bit Machine detected" -ForegroundColor Yellow
    Write-Host "Moving agent to report to $OSCE_server" -ForegroundColor Yellow
    UTF8Log -message "64-Bit Machine detected" -type "1" -component "$Component"
    UTF8Log -message "Moving agent to report to $OSCE_server" -type "1" -component "$Component"
    & $location\IpXfer_x64.exe -s $OSCE_server -p $http_port -sp $https_port -c $listening_port -e "$location\OfcNTCer.dat" -pwd "$password"
}

Start-Sleep 10 # This sleep is the only recommended one. The others are added to allow for output to be read before the script exits. The other ones can be removed if so desired. 

# Checks again for the server the agent is configured to report too.
$registeredServer = (Get-ItemProperty -Path $key -Name Server).Server

If($registeredServer -ne $OSCE_server){
    
    Write-Host "Agent did not move" -ForegroundColor Red
    UTF8Log -message "Agent did not move" -type "3" -component "$Component"
    $MoveIssue = 1
}

Write-Host "Execution Complete" -ForegroundColor Green
UTF8Log -message "Execution Complete" -type "1" -component "$Component"

Start-Sleep 20

# Exits with return code 5 if the agent did not move
if ($MoveIssue -eq 1){
    exit 5
}

# Exits with return code 0 if no issues occurred
exit 0