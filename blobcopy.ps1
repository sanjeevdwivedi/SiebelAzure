
#Change these to match the source account 

#$sourceStorageAccountName = "siebeldevvms" 

#$sourceContainerName = "vhds" 

#$sourceStorageKey = "Mz9CW/U6eEjILkebkMALoLcXhfZj2akPmShAj+hxa0wE0EISIgZccPSNLunZsm3jZBlBr9oFIqZGFYi8XP6eeg==" #Need this if moving data from a different subscription  

$sourceStorageAccountName = "siebelfull" 

$sourceContainerName = "vhds" 

$sourceStorageKey = "02OTNDMRnOKKY3BYVXLfxSGCBrtaSp4CyZowQf6oZv2OKOdxiejReEIPzrNZrmrH0SOp+2iDq/pfZCKt11wTKA==" #Need this if moving data from a different subscription  
  

#Destination Account Information  

#$destStorageAccountName = Read-Host "Enter Destination Storage Account Name" 

#$destStorageAccountKey = Get-AzureStorageKey $destStorageAccountName | %{$_.Primary} 

#$destContainerName = Read-Host "Enter Destination Container Name" 

$destStorageAccountName = "siebelartifacts" 

$destStorageAccountKey = "EwV92w9Wc3bGdUK72EytGEfAnUmWCkb7N7m44XOM/osuiSMofbgBhMT6lz1eChjhnObltd50MsoycQBM9SOCOw==" 

$destContainerName = "osdisks" 

  

$sourceContext = New-AzureStorageContext -StorageAccountName $sourceStorageAccountName -StorageAccountKey $sourceStorageKey -Protocol Http 

$destContext = New-AzureStorageContext -StorageAccountName $destStorageAccountName -StorageAccountKey $destStorageAccountKey 

  

#$uri = $sourceContext.BlobEndPoint + $sourceContainerName +"vhds/appsvr-osDisk.2439fa0e-ecc0-4ee1-8282-0afb6d162fc2.vhd" 

# Copy Operation 

#$SrcBlob = Get-AzureStorageBlob -Context $sourceContext -Container "vhds" -Blob "installs.vhd"
#$destBlob = Get-AzureStorageBlob -Context $destContext -Container "vhds" -Blob "installs.vhd"
#Start-AzureStorageBlobCopy -ICloudBlob $SrcBlob.ICloudBlob -DestICloudBlob $DestBlob.ICloudBlob

Get-AzureStorageBlob -Context $sourceContext -Container "vhds" -Blob "osdisk0.vhd" |
Start-AzureStorageBlobCopy -DestContext $destContext -DestContainer $destContainerName -DestBlob "osdisk0.vhd"

#Start-AzureStorageBlobCopy ` 

#        -SrcUri "$uri" ` 

#        -DestContext $destContext ` 

#        -DestContainer $destContainerName ` 

#        -DestBlob "installs.vhd"

#Get-AzureStorageBlob ` 

#    -Context $sourceContext ` 

#    -Container $sourceContainerName |  

#    ForEach-Object ` 

#    { Start-AzureStorageBlobCopy ` 

#        -SrcUri "$uri$($_.Name)" ` 

#        -DestContext $destContext ` 

#        -DestContainer $destContainerName ` 

#        -DestBlob "$($_.Name)" ` 

#    } 

#Checking Status of Blob Copy -- This can be commented out if no confirmation is needed  

#Get-AzureStorageBlob ` 

#    -Context $sourceContext ` #

#    -Container $sourceContainerName | 

#    ForEach-Object ` 

#    { Get-AzureStorageBlobCopyState ` 

#        -Blob $_.Name ` 

#        -Context $destContext ` 

#        -Container $destContainerName ` 

#        -WaitForComplete ` 

#    }


 
