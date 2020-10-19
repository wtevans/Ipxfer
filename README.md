# Ipxfer

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

