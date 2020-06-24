param (
    [ValidateSet("Dev")]
    [string]$Environment = $(Throw "Environment is required")
)

#load the enviroment variables from there
$PathToEnv = "..\terragrunt\infrastructure\$Environment"

$AccountInfo = Get-Content -raw -path "$PathToEnv\account.hcl.json" | ConvertFrom-JSON
$AccountSecretInfo = Get-Content -raw -path "$PathToEnv\account_secret.hcl.json" | ConvertFrom-JSON
$EnvironmentInfo = Get-Content -raw -path "$PathToEnv\env.hcl.json" | ConvertFrom-JSON

import-module az.storage

#connect to AZ using account info
$passwd = ConvertTo-SecureString $AccountSecretInfo.locals.client_secret -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential($AccountInfo.locals.client_id, $passwd)
Connect-AzAccount -ServicePrincipal -Credential $pscredential `
    -SubscriptionId $AccountInfo.locals.subscription_id `
    -TenantId $AccountInfo.locals.tenant_id | out-null

#get a sas tocken from the storage account
$destKey = (Get-AzStorageAccountKey -ResourceGroupName $EnvironmentInfo.locals.resource_group_name -AccountName $EnvironmentInfo.locals.cold_storage_account_name).Value[0]
$destContext = New-AzStorageContext -StorageAccountName $EnvironmentInfo.locals.cold_storage_account_name -StorageAccountKey $destKey
$sastoken = New-AzStorageShareSASToken -ShareName $EnvironmentInfo.locals.cold_storage_share_name -Context $destContext -Permission rwdlc -FullUri

#Enable detailed logging to file
[Environment]::SetEnvironmentVariable("PACKER_LOG", "1" ,"User")
$env:PACKER_LOG = [System.Environment]::GetEnvironmentVariable("PACKER_LOG","User")

#Set log file path
[Environment]::SetEnvironmentVariable("PACKER_LOG_PATH","$PSScriptRoot\packer.log" ,"User")
$env:PACKER_LOG_PATH = [System.Environment]::GetEnvironmentVariable("PACKER_LOG_PATH","User")

#Disable Packer phoning home to HashiCorp with telemetry data
[Environment]::SetEnvironmentVariable("CHECKPOINT_DISABLE", "1" ,"User")
$env:CHECKPOINT_DISABLE = [System.Environment]::GetEnvironmentVariable("CHECKPOINT_DISABLE","User")

packer build -force `
    -var "subscription_id=$($AccountInfo.locals.subscription_id)" `
    -var "tenant_id=$($AccountInfo.locals.tenant_id)" `
    -var "client_id=$($AccountInfo.locals.client_id)" `
    -var "client_secret=$($AccountSecretInfo.locals.client_secret)" `
    -var "resource_group_name=$($EnvironmentInfo.locals.resource_group_name)" `
    -var "cold_storage_account_name=$($EnvironmentInfo.locals.cold_storage_account_name)" `
    -var "cold_storage_share_name=$($EnvironmentInfo.locals.cold_storage_share_name)" `
    -var "sastoken=$($sastoken)" `
    .\gcdocs_windows_2016.json

#remove generated disks
#no longer needed due to terraform azure provider bug - no extra disks created
<#Write-Output "Removing Data Disks"
Get-AzDisk | where name -like "datadisk-?" | where 'ResourceGroupName' -eq $($EnvironmentInfo.locals.resource_group_name) | Remove-AzDisk -Force#>


