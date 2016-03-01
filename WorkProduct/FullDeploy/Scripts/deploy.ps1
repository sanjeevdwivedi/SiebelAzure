#Requires -Version 3.0

# To enable public access to system container:
# New-AzureStorageContext -StorageAccountKey Mz9CW...8XP6eeg== -StorageAccountName siebeldevvms
# Set-AzureStorageContainerAcl -Name system -Permission Container


Param(
  [string] [Parameter(Mandatory=$true)] $ResourceGroupLocation,
  [string] [Parameter(Mandatory=$true)] $ResourceGroupName  
)

$ResourceGroupName = 'siebelfull'
$ResourceGroupLocation = 'Central US'
$StorageTemplateFile = '..\Templates\Storage.json'
$VMTemplateFile = '..\Templates\NetworkWithVMs.json'
$StorageTemplateParametersFile = '..\Templates\Storage.param.json'
$VMTemplateParametersFile = '..\Templates\NetworkWithVMs.param.json'
$AzCopyPath = '..\Tools\AzCopy.exe'

if (Get-Module -ListAvailable | Where-Object { $_.Name -eq 'AzureResourceManager' -and $_.Version -ge '0.9.9' }) {
    Throw "The version of the Azure PowerShell cmdlets installed on this machine are not compatible with this script.  For help updating this script visit: http://go.microsoft.com/fwlink/?LinkID=623011"
}

Import-Module Azure -ErrorAction SilentlyContinue

try {
  [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("VSAzureTools-$UI$($host.name)".replace(" ","_"), "2.7.1")
} catch { }

Set-StrictMode -Version 3
# $PSScriptRoot == $DirRoot
$DirRoot = 'C:\Users\mrochon\Documents\Premier\Siebel\FullDeploy\Scripts\'

$StorageTemplateFile = [System.IO.Path]::Combine($DirRoot, $StorageTemplateFile)
$StorageTemplateParametersFile = [System.IO.Path]::Combine($DirRoot, $StorageTemplateParametersFile)

$AzCopyPath = [System.IO.Path]::Combine($DirRoot, $AzCopyPath)

# Parse the parameter file and update the values of artifacts location and artifacts location SAS token if they are present
$JsonContent = Get-Content $StorageTemplateParametersFile -Raw | ConvertFrom-Json
$JsonParameters = $JsonContent | Get-Member -Type NoteProperty | Where-Object {$_.Name -eq "parameters"}

if ($JsonParameters -eq $null) {
    $JsonParameters = $JsonContent
}
else {
    $JsonParameters = $JsonContent.parameters
}

# Create or update the resource group using the storage account creation template
Switch-AzureMode AzureResourceManager
New-AzureResourceGroup -Name $ResourceGroupName `
                       -Location $ResourceGroupLocation `
                       -TemplateFile $StorageTemplateFile `
                       -TemplateParameterFile $StorageTemplateParametersFile `
                        -Force -Verbose

#TODO: Has the above succeeded?
# copy the vm images into the new storage account
$StorageAccountName = $JsonParameters.newStorageAccountName.value
$StorageAccountKey = (Get-AzureStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Key1
$StorageAccountContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

$VMTemplateFile = [System.IO.Path]::Combine($DirRoot, $VMTemplateFile)
$VMTemplateParametersFile = [System.IO.Path]::Combine($DirRoot, $VMTemplateParametersFile)
# Parse the parameter file and update the values of artifacts location and artifacts location SAS token if they are present
#$JsonContent = Get-Content $VMTemplateParametersFile -Raw | ConvertFrom-Json
#$JsonParameters = $JsonContent | Get-Member -Type NoteProperty | Where-Object {$_.Name -eq "parameters"}

$ImageSource = 'https://siebeldevvms.blob.core.windows.net/system'
$Dest = $StorageAccountContext.BlobEndPoint + 'system'

& $AzCopyPath /Source:$ImageSource, /Dest:$Dest, /Pattern:'Microsoft.Compute/Images/system/', /DestKey:$StorageAccountKey, "/S", "/XO", "/Y", "/V", "/Z:$DirRoot"

# create the rest of the setup (vnet, ip, vm) using the 2nd template
New-AzureResourceGroup -Name $ResourceGroupName `
                       -Location $ResourceGroupLocation `
                       -TemplateFile $VMTemplateFile `
                       -TemplateParameterFile $VMTemplateParametersFile `
                       -Force -Verbose
