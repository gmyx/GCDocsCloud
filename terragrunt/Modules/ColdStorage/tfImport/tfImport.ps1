#a proxy to mask import errors, if resource already imported
param (
    [string]$SubscriptionID,
    [string]$ResourceGroupName,
    [string]$StorageAccountName,
    [string]$ShareName
)

#terraform import azurerm_storage_account.storageAcc1 /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myresourcegroup/providers/Microsoft.Storage/storageAccounts/myaccount
write-host "Importing Storage Account" -ForegroundColor Blue -BackgroundColor White
$results1 = & terraform import "azurerm_storage_account.gcdocsinstallers" "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/$StorageAccountName" 2>&1 | out-string

#terraform import azurerm_storage_share.exampleShare https://account1.file.core.windows.net/share1
write-host "Importing Share" -ForegroundColor Blue -BackgroundColor White
$results2 = & terraform import "azurerm_storage_share.coldshare" "https://$StorageAccountName.file.core.windows.net/$ShareName" 2>&1 | out-string

#prep exit ExitCode
$ExitCode = 0

#in theory, we only want to mask: Resource already managed by Terraform
if (($results1 -notmatch "Resource already managed by Terraform") -and
    ($results1 -notmatch "Import successful!") -and
    ($results1 -notmatch "Cannot import non-existent remote object") -eq $true) {

    #an error to not ingore
    write-host $results1 -ForegroundColor Blue -BackgroundColor White
    $ExitCode = $ExitCode + 1
}

#in theory, we only want to mask: Resource already managed by Terraform
if (($results2 -notmatch "Resource already managed by Terraform") -and
    ($results2 -notmatch "Import successful!") -and
    ($results2 -notmatch "Cannot import non-existent remote object") -eq $true) {

    #an error to not ingore
    write-host $results2 -ForegroundColor Blue -BackgroundColor White
    $ExitCode = $ExitCode + 1
}

Exit $ExitCode