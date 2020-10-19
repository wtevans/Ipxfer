# Ipxfer

.SYNOPSIS
Ipxfer Script

By: wtevans

This script is designed to move agents to another osce server or update certificates using the ipxfer tool from TrendMicro

.Description

This scripted is designed to run the ipxfer to either move agents to another server or update the certificate if there is a mismatched certificate issue.   
For this script to function properly you will need to place both of the ipxfer's (64 bit and 32 bit versions) in the same running directory as this script. The ipxfer 
can be found on the Officescan/ApexOne on-prem server [Server Install Path]\PCCSRV\Admin\Utility\IpXfer. You will also need the ofcntcert.dat file in the same running directory
as well found at [Server Path]\PCCSRV\Pccnt\Common\OfcNTCer.dat. There is a section in the body of the script called "Specified Variables" that need to be modified 
for environment-specific information. For more information on ipxfer please use the links listed below. 

.NOTES 
- A utf8 log should be output in the executing users %temp% directory for reference.
- The update certificate option can be disabled to make the script only move agents if they are reporting to the wrong server if so desired. To modify this check the "Specified Variables" section of the script.
- If deployed with a deployment tool the ipxfer tools, ofcntcert.dat, and this script need to be in the same directory and run from that directory as well to function. 


.EXAMPLE
./ipxfer.ps1

.Link
Trend Micro KB's for ipxfer:
https://success.trendmicro.com/solution/0127004-manually-transferring-or-re-establishing-communication-between-officescan-apex-one-agents-and-server
https://success.trendmicro.com/solution/1102851-officescan-agents-do-not-have-a-valid-officescan-server-certificate-appears-on-the-dashboard

