net user SADMIN $windows_sadmin_password
net user SIEBEL $windows_siebel_password
sc.exe config gtwyns obj= ".\SADMIN" password= "$windows_sadmin_password"
net start gtwyns
C:\Siebel\ses\gtwysrvr\bin\srvrmgr.exe /u SADMIN /p s3e0123* /g gateway /e siebel /c "change ent param Password='$db_sadmin_password'"
net stop gtwyns
sc config gtwyns start= auto