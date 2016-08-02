param(
[string]$windows_sadmin_password,
[string]$windows_siebel_password,
[string]$db_sadmin_password
)

Write-Output "custom script execution start"

# Create basic Windows users
net user /ADD SADMIN $windows_sadmin_password /EXPIRES:NEVER
net user /ADD SIEBEL $windows_siebel_password /EXPIRES:NEVER

Write-Output "SADMIN and SIEBEL users added"

# Add to the Administrators group
net localgroup Administrators SADMIN SIEBEL /ADD

Write-Output "SIEBEL user added to Administrators group"

# Grant "Log on as a Service" to SADMIN
$objUser = New-Object System.Security.Principal.NTAccount("gateway\SADMIN") 
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

Write-Output "LogOnAsAService updated"

# Change Gateway to use SADMIN user
sc.exe config gtwyns obj= ".\SADMIN" password= "$windows_sadmin_password" type= own start= auto

Write-Output "Changed gateway to use SADMIN"

# Start Gateway
net start gtwyns

# Update DB password stored in Gateway to new password
C:\Siebel\gtwysrvr\bin\srvrmgr.exe /u SADMIN /p $db_sadmin_password /g gateway /e siebel /c "change ent param Password='$db_sadmin_password'"
	
Write-Output "db password stored in gateway has been updated"

# Stop and start the service to allow it to use the new password
net stop gtwyns
net start gtwyns

Write-Output "custom script execution complete"
