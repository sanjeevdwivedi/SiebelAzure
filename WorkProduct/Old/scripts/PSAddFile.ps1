
param(
[string]$fileName
)

"This file was written to a file path from the ARM template." | Out-File C:\$fileName -encoding Unicode

