#a proxy to mask import errors, if resource already imported
param (
    [string]$SubscriptionID,
    [string]$ResourceGroupName,
    [string]$StorageAccountName
)

write-host "Importing Storage Account" -ForegroundColor Blue -BackgroundColor White
$results = & terraform import "azurerm_storage_account.gcdocsinstallers" "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/StorageAccountName" 2>&1 | out-string

#in theory, we only want to mask: Resource already managed by Terraform
#I also need to see when an import is succesfull (TBD)
#if (($results -match "Resource already managed by Terraform") -eq $true) {
    #ignore this error, we are in a good state
    exit 0 #return no error
#} else {
#    throw $results #bail!
#}
