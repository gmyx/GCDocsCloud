#a proxy to mask import errors, if resource already imported
param (
    [string]$SubscriptionID,
    [string]$ResourceGroupName,
    [string]$AutomationAccountName
)

#terraform import azurerm_automation_account.account1 /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1/providers/Microsoft.Automation/automationAccounts/account1
write-host "Importing Automation Account" -ForegroundColor Blue -BackgroundColor White
$results1 = & terraform import "azurerm_automation_account.GCDOCS-DSC" "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$AutomationAccountName" 2>&1 | out-string

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