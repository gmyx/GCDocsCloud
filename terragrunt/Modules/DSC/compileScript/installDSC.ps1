#adapted from https://www.reddit.com/r/Terraform/comments/ct19q4/azure_vm_dsc_configuration/
param (
    [string]$subscription_id = $(throw 'subscription_id is required'),
    [string]$tenant_id = $(throw 'tenant_id is required'),
    [string]$client_id = $(throw 'client_id is required'),
    [string]$client_secret = $(throw 'client_secret is required'),
    [string]$configName = $(throw 'configName is required'),
    [string]$automationAccountName = $(throw 'automationAccountName is required'),
    [string]$resourceGroupName = $(throw 'resourceGroupName is required')
)

Import-Module Az.Automation

Function Connect-WithCreds {
    param (
        [string]$subscription_id,
        [string]$tenant_id,
        [string]$client_id ,
        [string]$client_secret
    )

    #Create a credentials object from client id and client secret
    $SecurePass = ConvertTo-SecureString -String $client_secret -AsPlainText -force
    $Creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $client_id,$SecurePass

    Connect-AzAccount -ServicePrincipal -Credential $Creds -Tenant $tenant_id -Subscription $subscription_id
    Set-AzContext -subscriptionid $subscription_id
}

Function CompileDSCConfiguration{
    Param(
        [string]$configName,
        [string]$automationAccountName,
        [string]$resourceGroupName
    )

    $ConfigData = @{
        AllNodes = @(
            @{
                NodeName = 'localhost'
                #PSDscAllowPlainTextPassword = $true
                PSDscAllowDomainUser = $true
            }
        )
    }

    $compParams = @{
        AutomationAccountName = $automationAccountName
        ResourceGroupName = $resourcegroupname
        ConfigurationName = $configName
        ConfigurationData = $ConfigData
    }

    #start it and forget about it - move on!
    $CompilationJob = Start-AzAutomationDscCompilationJob @compParams
}

Connect-WithCreds -subscription_id $subscription_id -tenant_id $tenant_id -client_id $client_id -client_secret $client_secret
$null = CompileDSCConfiguration -configName $configName -automationAccountName $automationAccountName -resourceGroupName $resourceGroupName