param([bool] $deleteExisting)

if(deleteExisting){
    Write-Output "Checking if resource group agSiebelTest exists"
    $rg = Get-AzureRmResourceGroup -Name "agSiebelTest"

    if($rg -ne $null){
        # delete existing resource group
        Write-Output "Deleteing resource group agSiebelTest"
        Remove-AzureRmResourceGroup -Name "agSiebeltest" -Force 

        while($rg -ne $null){
            Start-Sleep -Seconds 30
            Write-Output "Checking if resource group agSiebelTest still exists"
            $rg = Get-AzureRmResourceGroup -Name "agSiebelTest"
            if($rg -ne $null){
                Write-Output "Resource group agSiebelTest still exists"
            }
            else{
                Write-Output "resource group agSiebelTest deleted"
            }
        }

        #remove VHD blobs from previous deployment
        Write-Output "Removing vhd blobs from previous deployment"
        $storageContext = New-AzureStorageContext -StorageAccountName "siebelartifacts" -StorageAccountKey "EwV92w9Wc3bGdUK72EytGEfAnUmWCkb7N7m44XOM/osuiSMofbgBhMT6lz1eChjhnObltd50MsoycQBM9SOCOw=="
        Get-AzureStorageBlob -Container "vhds" | Remove-AzureStorageBlob
    }

    #re-create resource group
    Write-Output "Re-creating resource group agSiebelTest"
    New-AzureRmResourceGroup -Name "agSiebeltest" -Location "Central US"
}
# new deployment
Write-Output "Deploying assets"
New-AzureRmResourceGroupDeployment -ResourceGroupName "agSiebeltest" -TemplateFile "NetworkWithVMsGeneralized.json" -TemplateParameterFile "NetworkWithVMs.param.json"
