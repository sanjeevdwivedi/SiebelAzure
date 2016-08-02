param(
[string]$windows_sadmin_password,
[string]$windows_siebel_password,
[string]$db_sadmin_password
)

Write-Output "custom script execution start"
# Create basic Siebel users
net user /ADD SADMIN $windows_sadmin_password /EXPIRES:NEVER
net user /ADD SIEBEL $windows_siebel_password /EXPIRES:NEVER

# Add to the Administrators group
net localgroup Administrators SADMIN SIEBEL /ADD

Write-Output "users added"

# Grant "Log on as a Service" to SADMIN
$objUser = New-Object System.Security.Principal.NTAccount("AppVM0\SADMIN") 
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier]) 
$MySID = $strSID.Value 
secedit /export /cfg tempexport.inf 
$curSIDs = Select-String .\tempexport.inf -Pattern "SeServiceLogonRight" 
$Sids = $curSIDs.line 
copy .\LogOnAsAService.inf .\LogOnAsAServiceTemplate.inf 
add-content .\LogOnAsAServiceTemplate.inf "$Sids,*$MySID" 
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition 
secedit /import /db secedit.sdb /cfg "$scriptPath\LogOnAsAServiceTemplate.inf" 
secedit /configure /db secedit.sdb 
gpupdate /force 
del ".\LogOnAsAServiceTemplate.inf" -force 
del ".\secedit.sdb" -force 
del ".\tempexport.inf" -force

# Make sure old service is stopped
net stop siebsrvr_siebel_AppVM0

$services = "siebsrvr_siebel_AppVM0"
$status = "Stopped"
$maxRepeat = 20

do 
{
	$maxRepeat--
   	sleep -Milliseconds 30000
	$count = (Get-Service $services | ? {$_.status -eq $status}).count    
} until ($count -eq 1 -or $maxRepeat -eq 0)

# Delete old version of Siebel Server service (far easier than attempting to change)
c:\siebel\siebsrvr\bin\siebctl -d -S siebsrvr -i "siebel_AppVM0"

# Create a new version of the Siebel Service service
c:\siebel\siebsrvr\bin\siebctl -h "C:\siebel\siebsrvr" -S siebsrvr -i "siebel_AppVM0" -a -g "-g gateway:2320 -e siebel -s AppVM0 -u SADMIN" -e $db_sadmin_password -u .\SADMIN -p $windows_sadmin_password

# Configure it to start automatically, but with short delay
sc.exe config siebsrvr_siebel_AppVM0 start= delayed-auto

# Start the Siebel Server process
net start siebsrvr_siebel_AppVM0

Write-Output "custom script execution complete"