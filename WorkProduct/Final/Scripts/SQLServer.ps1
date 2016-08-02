param(
[string]$db_sadmin_password,
[string]$db_siebel_password,
[string]$db_guestcst_password,
[string]$db_guesterm_password,
[string]$db_sa_password,
[string]$windows_siebel_password
)
# Update key database user passwords
sqlcmd -U sa -P s3e0123* -Q "ALTER LOGIN [SADMIN] WITH PASSWORD='$db_sadmin_password'"
sqlcmd -U sa -P s3e0123* -Q "ALTER LOGIN [SIEBEL] WITH PASSWORD='$db_siebel_password'"
sqlcmd -U sa -P s3e0123* -Q "ALTER LOGIN [GUESTCST] WITH PASSWORD='$db_guestcst_password'"
sqlcmd -U sa -P s3e0123* -Q "ALTER LOGIN [GUESTERM] WITH PASSWORD='$db_guesterm_password'"
sqlcmd -U sa -P s3e0123* -Q "ALTER LOGIN [sa] WITH PASSWORD='$db_sa_password'"

# Create basic Windows user as a fallback if ever needed
net user /ADD SIEBEL $windows_siebel_password /EXPIRES:NEVER

# Add to the Administrators group
net localgroup Administrators SIEBEL /ADD
