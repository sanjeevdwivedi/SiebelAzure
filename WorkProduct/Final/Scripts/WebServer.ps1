param(
[string]$config_file,
[string]$windows_siebel_password,
[string]$db_guestcst_password,
[string]$db_guesterm_password,
[string]$ent_token
)

###### functions

function Replace-Values
{
    param(
    [string]$OriginalFile, 
    [string]$OldCstPswd,
    [string]$NewCstPswd,
    [string]$OldErmPswd,
    [string]$NewErmPswd,
    [string]$OldToken,
    [string]$NewToken
    )

    $destination_file =  $OriginalFile + '.new'

    (Get-Content $OriginalFile) | Foreach-Object {        
        $_ -replace [Regex]::Escape($OldCstPswd), $NewCstPswd`
         -replace [Regex]::Escape($OldErmPswd), $NewErmPswd`
         -replace [Regex]::Escape($OldToken), $NewToken
        } | Set-Content $destination_file

    #Swap the file names
    $bak_file = ($OriginalFile + '{0:yyyyMMddhhmmss}.bak' -f (Get-Date))
    Rename-Item $OriginalFile $bak_file
    Rename-Item $destination_file $OriginalFile
}

function Get-Token
{
    param ([string]$File)

    $tokenline = (Select-String -Path $File -List -Pattern "SiebEntSecToken").Line
    $oldtoken = $tokenline.Substring(($tokenline.LastIndexOf("= "))+2)
    return $oldtoken
}

function Get-Password
{
    param (
    [string]$User, 
    [string]$File)

    $pswdlinenum = (Select-String -Path $File -List -Pattern "AnonUserName  = $User").LineNumber
    # zero-based index
    $pswdline = Get-Content $File | Select-Object -Index $pswdlinenum
    #$pswdline = Get-PswdLine $term
    $oldpswd = $pswdline.Substring(($pswdline.LastIndexOf("= "))+2)
    return $oldpswd
}


###### processing code

Write-Output "custom script execution start"

#get existing passwords in file for replacing later
$old_db_guestcst_password = Get-Password -User 'GUESTCST' -File $config_file
$old_db_guesterm_password = Get-Password -User 'GUESTERM' -File $config_file
$old_token = Get-Token -File $config_file


#when not running in debug mode: encrypt values, get new values from text file, delete file
$debug = Test-Path Variable:PSDebugContext
if(!($debug))
{
	# Create basic Windows user
	net user /ADD SIEBEL $windows_siebel_password /EXPIRES:NEVER

	# Add to the Administrators group
	net localgroup Administrators SIEBEL /ADD

	mkdir c:\Siebel\Scripts
	C:\Siebel\eappweb\BIN\encryptstring.exe $db_guesterm_password > C:\Siebel\scripts\guesterm.txt
   	$db_guesterm_password = Get-Content C:\Siebel\scripts\guesterm.txt

	C:\Siebel\eappweb\BIN\encryptstring.exe $db_guestcst_password > C:\Siebel\scripts\guestcst.txt
	$db_guestcst_password = Get-Content C:\Siebel\scripts\guestcst.txt

	C:\Siebel\eappweb\BIN\encryptstring.exe $ent_token > C:\Siebel\scripts\ent-token.txt
	$ent_token = Get-Content C:\Siebel\scripts\ent-token.txt

	del C:\Siebel\scripts\guesterm.txt
	del C:\Siebel\scripts\guestcst.txt
	del C:\Siebel\scripts\ent-token.txt
	rmdir c:\Siebel\Scripts
}

Replace-Values -OriginalFile $config_file -OldCstPswd $old_db_guestcst_password -NewCstPswd $db_guestcst_password -OldErmPswd $old_db_guesterm_password -NewErmPswd $db_guesterm_password -OldToken $old_token -NewToken $ent_token

Write-Output "custom script execution complete"