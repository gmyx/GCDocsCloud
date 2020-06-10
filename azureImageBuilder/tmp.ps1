param([switch]$SkipCleanup)
. .\makeImage.ps1 -resourceGroupName GCDOCS-dev-rg -location "eastus" `
    -vnetName "GCDOCS-dev-vnet" -subnetName "GCDOCS-dev-subnet" -nsgName "templateNSG" -SkipCleanup:$SkipCleanup