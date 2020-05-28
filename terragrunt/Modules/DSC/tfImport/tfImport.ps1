#a proxy to mask import errors, if resource already imported
param (
    [string]$subscription_id = $(throw 'subscription_id is required'),
    [string]$tenant_id = $(throw 'tenant_id is required'),
    [string]$client_id = $(throw 'client_id is required'),
    [string]$client_secret = $(throw 'client_secret is required'),
    [string]$resource_group_name = $(throw 'resource_group_name is required'),
    [string]$automation_account_name = $(throw 'automation_account_name is required')
)

<# list of modules to manage
* StorageDSC
* ComputerManagementDsc
#>

#Create a credentials object from client id and client secret
$SecurePass = ConvertTo-SecureString -String $client_secret -AsPlainText -force
$Creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $client_id,$SecurePass

#connect to AZ
Connect-AzAccount -ServicePrincipal -Credential $Creds -Tenant $tenant_id -Subscription $subscription_id
Set-AzContext -subscriptionid $subscription_id


#StorageDSC
write-host "Importing StorageDSC" -ForegroundColor Blue -BackgroundColor White
$results1 = & terraform import "azurerm_automation_module.StorageDSC" "/subscriptions/$subscription_id/resourceGroups/$resource_group_name/providers/Microsoft.Automation/automationAccounts/$automation_account_name/modules/StorageDSC" 2>&1 | out-string

#ComputerManagementDsc
write-host "Importing ComputerManagementDsc" -ForegroundColor Blue -BackgroundColor White
$results2 = & terraform import "azurerm_automation_module.ComputerManagementDsc" "/subscriptions/$subscription_id/resourceGroups/$resource_group_name/providers/Microsoft.Automation/automationAccounts/$automation_account_name/modules/ComputerManagementDsc" 2>&1 | out-string

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
} else {
    #try to trigger an update
    $moduleName = "ComputerManagementDsc"
    $moduleVersion = "8.2.0"
    $Params = @{
        AutomationAccountName = $automation_account_name
        ResourceGroupName = $resource_group_name
        Name = $moduleName
        ContentLinkUri = "https://www.powershellgallery.com/api/v2/package/$moduleName/$moduleVersion"
    }
    New-AzAutomationModule @Params

    #wait until it is imported

}

Exit $ExitCode