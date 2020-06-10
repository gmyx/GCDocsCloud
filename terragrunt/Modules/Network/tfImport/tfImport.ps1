#a proxy to mask import errors, if resource already imported
param (
    [string]$SubscriptionID,
    [string]$ResourceGroupName,
    [string]$Environment
)

#terraform import azurerm_virtual_network.exampleNetwork /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mygroup1/providers/Microsoft.Network/virtualNetworks/myvnet1
write-host "Importing Virtual Networks" -ForegroundColor Blue -BackgroundColor White
$results1 = & terraform import "azurerm_virtual_network.vnet" "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Network/virtualNetworks/GCDOCS-$Environment-vnet" 2>&1 | out-string

#terraform import azurerm_subnet.exampleSubnet /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mygroup1/providers/Microsoft.Network/virtualNetworks/myvnet1/subnets/mysubnet1
write-host "Importing Subnets" -ForegroundColor Blue -BackgroundColor White
$results2 = & terraform import "azurerm_subnet.subnet" "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Network/virtualNetworks/GCDOCS-$Environment-vnet/subnets/GCDOCS-$Environment-subnet" 2>&1 | out-string

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

if (($results2 -notmatch "Resource already managed by Terraform") -and
    ($results2 -notmatch "Import successful!") -and
    ($results2 -notmatch "Cannot import non-existent remote object") -eq $true) {

    #an error to not ingore
    write-host $results2 -ForegroundColor Blue -BackgroundColor White
    $ExitCode = $ExitCode + 1
}


Exit $ExitCode