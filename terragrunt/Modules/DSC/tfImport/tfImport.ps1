#a proxy to mask import errors, if resource already imported
param (
    [string]$subscriptionID = $(throw 'subscriptionID is required'),
    [string]$tenantID = $(throw 'tenantID is required'),
    [string]$clientID = $(throw 'clientID is required'),
    [string]$clientSecret = $(throw 'clientSecret is required'),
    [string]$resourceGroupName = $(throw 'resourceGroupName is required'),
    [string]$automationAccountName = $(throw 'automationAccountName is required')
)

<# list of modules to manage
* StorageDSC
* ComputerManagementDsc
#>

#Create a credentials object from client id and client secret
$SecurePass = ConvertTo-SecureString -String $clientSecret -AsPlainText -force
$Creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $clientID,$SecurePass

#connect to AZ
Connect-AzAccount -ServicePrincipal -Credential $Creds -Tenant $tenantID -Subscription $subscriptionID
Set-AzContext -subscriptionid $subscriptionID

#StorageDSC
write-host "Importing StorageDSC" -ForegroundColor Blue -BackgroundColor White
$results1 = & terraform import "azurerm_automation_module.StorageDSC" "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.Automation/automationAccounts/$automationAccountName/modules/StorageDSC" 2>&1 | out-string

#ComputerManagementDsc
write-host "Importing ComputerManagementDsc" -ForegroundColor Blue -BackgroundColor White
$results2 = & terraform import "azurerm_automation_module.ComputerManagementDsc" "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.Automation/automationAccounts/$automationAccountName/modules/ComputerManagementDsc" 2>&1 | out-string

#azurerm_automation_credential for the systems to access the 'isntallers storage z' drive
#terraform import azurerm_automation_credential.credential1 /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1/providers/Microsoft.Automation/automationAccounts/account1/credentials/credential1
write-host "Importing azurerm_automation_credential" -ForegroundColor Blue -BackgroundColor White
$results3 = & terraform import "azurerm_automation_credential.fileShare" "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.Automation/automationAccounts/$automationAccountName/credentials/fileShare" 2>&1 | out-string

#azurerm_automation_dsc_configuration
#terraform import azurerm_automation_dsc_configuration.configuration1 /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1/providers/Microsoft.Automation/automationAccounts/account1/configurations/configuration1
$results4 = & terraform import "azurerm_automation_dsc_configuration.GCDOCS-DSC" "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.Automation/automationAccounts/$automationAccountName/configurations/GCDOCSDsc" 2>&1 | out-string

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

    #set-up initial get
    $GetParams = @{
        AutomationAccountName = $automationAccountName
        ResourceGroupName = $resourceGroupName
        Name = $moduleName
    }
    $Status = Get-AzAutomationModule @GetParams

    #check version
    if ($Status.Version -ne $moduleVersion) {
        $Params = @{
            AutomationAccountName = $automationAccountName
            ResourceGroupName = $resourceGroupName
            Name = $moduleName
            ContentLinkUri = "https://www.powershellgallery.com/api/v2/package/$moduleName/$moduleVersion"
        }
        New-AzAutomationModule @Params

        #wait until it is imported

        $Tries = 0
        $Status = Get-AzAutomationModule @GetParams
        while ($Status.ProvisioningState -ne "Succeeded" -and $Tries -lt 20) {
            write-host "Waiting for module to be imported. Current Status $($Status.ProvisioningState)"  -ForegroundColor Blue -BackgroundColor White
            start-sleep -seconds 5
            $Tries = $Tries + 1 #emerg break out
            $Status = Get-AzAutomationModule @GetParams
        }

        if ($Tries -ge 20) {exit 1} #error
    }
}

#in theory, we only want to mask: Resource already managed by Terraform
if (($results3 -notmatch "Resource already managed by Terraform") -and
    ($results3 -notmatch "Import successful!") -and
    ($results3 -notmatch "Cannot import non-existent remote object") -eq $true) {

    #an error to not ingore
    write-host $results3 -ForegroundColor Blue -BackgroundColor White
    $ExitCode = $ExitCode + 1
}

if (($results4 -notmatch "Resource already managed by Terraform") -and
    ($results4 -notmatch "Import successful!") -and
    ($results4 -notmatch "Cannot import non-existent remote object") -eq $true) {

    #an error to not ingore
    write-host $results4 -ForegroundColor Blue -BackgroundColor White
    $ExitCode = $ExitCode + 1
}


Exit $ExitCode