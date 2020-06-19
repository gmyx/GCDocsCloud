#a proxy to mask import errors, if resource already imported
param (
    [string]$SubscriptionID,
    [string]$ResourceGroupName,
    [string]$KeyVaultName
)

#terraform import azurerm_key_vault.example /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mygroup1/providers/Microsoft.KeyVault/vaults/vault1

write-host "Importing Resrouce Group" -ForegroundColor Blue -BackgroundColor White
$results1 = & terraform import "azurerm_key_vault.KeyVault" "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.KeyVault/vaults/$KeyVaultName" 2>&1 | out-string

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


Exit $ExitCode