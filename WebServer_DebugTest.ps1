
$config_file = "C:\Git\Source\Repos\SiebelAzure\WorkProduct\eapps.cfg"
$windows_siebel_password = "WindowsUser"
$cst_pswd = "CSTPSWD"
$cst_user_name = "GUESTCST"
$erm_user_name = "GUESTERM"
$erm_pswd = "ERMPSWD"
$ent_token = "ENTTOKEN"


#get existing passwords in file for replacing later
$old_cst_pswd = Get-Password -User $cst_user_name -File $config_file
$old_erm_pswd = Get-Password -User $erm_user_name -File $config_file
$old_token = Get-Token -File $config_file


#when not running in debug mode: encrypt values, get new values from text file, delete file
$debug = Test-Path Variable:PSDebugContext
if($debug -ne $false)
{
    net user SIEBEL $windows_siebel_password

    C:\Siebel\eappweb\BIN\encryptstring.exe $erm_pswd > C:\Siebel\scripts\guesterm.txt
    $erm_pswd = Get-Content C:\Siebel\scripts\guesterm.txt

    C:\Siebel\eappweb\BIN\encryptstring.exe $cst_pswd > C:\Siebel\scripts\guestcst.txt
    $cst_pswd = Get-Content C:\Siebel\scripts\guestcst.txt

    C:\Siebel\eappweb\BIN\encryptstring.exe $ent_token > C:\Siebel\scripts\ent-token.txt
    $ent_token = Get-Content C:\Siebel\scripts\ent-token.txt

    del C:\Siebel\scripts\guesterm.txt
    del C:\Siebel\scripts\guestcst.txt
    del C:\Siebel\scripts\ent-token.txt
}

Replace-Values -OriginalFile $config_file -OldCstPswd $old_cst_pswd -NewCstPswd $cst_pswd -OldErmPswd $old_erm_pswd -NewErmPswd $erm_pswd -OldToken $old_token -NewToken $ent_token

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
         -replace [Regex]::Escape($OldErmPswd), $NewCstPswd`
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
