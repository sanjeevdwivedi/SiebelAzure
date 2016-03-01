net user SIEBEL $windows_siebel_password

C:\Siebel\eappweb\BIN\encryptstring.exe $db_guesterm_password > C:\Siebel\scripts\guesterm.txt
$guestermpwd = Get-Content C:\Siebel\scripts\guesterm.txt

C:\Siebel\eappweb\BIN\encryptstring.exe $db_guestcst_password > C:\Siebel\scripts\guestcst.txt
$guestcstpwd = Get-Content C:\Siebel\scripts\guestcst.txt

C:\Siebel\eappweb\BIN\encryptstring.exe $ent_token > C:\Siebel\scripts\ent-token.txt
$enttokenpwd = Get-Content C:\Siebel\scripts\ent-token.txt

c:\Siebel\scripts\UpdateAnonPassword.vbs C:\siebel\eappweb\bin\eapps.cfg GUESTCST $guestcstpwd
c:\Siebel\scripts\UpdateAnonPassword.vbs C:\siebel\eappweb\bin\eapps.cfg GUESTERM $guestermpwd
c:\Siebel\scripts\UpdateEnterpriseToken.vbs C:\siebel\eappweb\bin\eapps.cfg $enttokenpwd

del C:\Siebel\scripts\guesterm.txt
del C:\Siebel\scripts\guestcst.txt
del C:\Siebel\scripts\ent-token.txt