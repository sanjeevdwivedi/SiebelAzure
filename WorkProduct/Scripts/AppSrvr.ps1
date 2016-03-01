net user SADMIN $windows_sadmin_password
net user SIEBEL $windows_siebel_password
c:\siebel\siebsrvr\bin\siebctl -d -S siebsrvr -i "siebsrvr_siebel_AppVM0"
c:\siebel\siebsrvr\bin\siebctl -h C:\siebel\siebsrvr -S AppVM0 -i "siebel_AppVM0" -a -g "-g gateway:2320 -e siebel -s AppVM0 -u sadmin" -e $db_sadmin_password -u .\SADMIN -p $windows_siebel_password
sc config siebsrvr_siebel_AppVM0 start= delayed-auto
