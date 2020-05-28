#adapted from https://www.reddit.com/r/Terraform/comments/ct19q4/azure_vm_dsc_configuration/
param (
    [string]$subscription_id = $(throw 'subscription_id is required'),
    [string]$tenant_id = $(throw 'tenant_id is required'),
    [string]$client_id = $(throw 'client_id is required'),
    [string]$client_secret = $(throw 'client_secret is required'),
    [string]$configName = $(throw 'configName is required'),
    [string]$automationAccountName = $(throw 'automationAccountName is required'),
    [string]$resourceGroupName = $(throw 'resourceGroupName is required'),
    [string]$Environment = $(throw 'Environment is required'),
    [string]$NetworkSharePath = $(throw 'NetworkSharePath is required'),
    [string]$StorageAccountName = $(throw 'StorageAccountName is required'),
    [string]$NetworkShareCredentialName = $(throw 'NetworkShareCredentialName is required')
)

Import-Module Az.Automation

Function Connect-WithCreds {
    param (
        [string]$subscription_id,
        [string]$tenant_id,
        [string]$client_id,
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
        [string]$resourceGroupName,
        [string]$NetworkSharePath,
        [string]$StorageAccountName,
        [string]$NetworkShareCredentialName

    )

    $ConfigData = @{
        AllNodes = @(
            @{
                NodeName = 'localhost'
                PSDscAllowPlainTextPassword = $true #needed for Creds
                PSDscAllowDomainUser = $true
            }
        )
    }

    #NetworkSharePath needs to be massaged to remote http:// and trailling /
    $Pattern = "https:\/\/(.*)\/"
    $NetworkSharePath -match $Pattern
    $NetworkSharePath = $Matches[1]

    #custom params to send to the compiller to include in the DSC
    #this is how we pass the vars need to connect to cold storage
    $Params = @{
        Environment = $Environment
        NetworkSharePath = $NetworkSharePath
        NetworkShareCredentialName = $NetworkShareCredentialName
        StorageAccountName = $StorageAccountName
    }

    $compParams = @{
        AutomationAccountName = $automationAccountName
        ResourceGroupName = $resourcegroupname
        ConfigurationName = $configName
        ConfigurationData = $ConfigData
        Parameters = $Params
    }

    #start it and forget about it - move on!
    $CompilationJob = Start-AzAutomationDscCompilationJob @compParams
}

write-host "Compiling DSC" -ForegroundColor Blue -BackgroundColor White
Connect-WithCreds -subscription_id $subscription_id -tenant_id $tenant_id -client_id $client_id -client_secret $client_secret
$Params = @{
    configName = $configName
    automationAccountName = $automationAccountName
    resourceGroupName = $resourceGroupName
    NetworkSharePath = $NetworkSharePath
    StorageAccountName = $StorageAccountName
    NetworkShareCredentialName = $NetworkShareCredentialName
}
$null = CompileDSCConfiguration @Params