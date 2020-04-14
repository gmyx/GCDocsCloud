[CmdletBinding()]
Param (
    [string]$ConfigFile = $(Throw "ConfigFile is required")
)

$Config = Import-PowerShellDataFile -Path $ConfigFile

$SecurePassword = ConvertTo-SecureString -String $Config.client_secret -AsPlainText -Force
$SPCredential = [pscredential]::new($Config.client_id, $SecurePassword)
Connect-AzAccount -ServicePrincipal -Credential $SPCredential -Tenant $Config.tenant_id | Out-Null

& terraform apply -var subscription_name=$($Config.subscription_name) `
    -var subscription_id=$($Config.subscription_id) `
    -var client_secret=$($Config.client_secret) `
    -var tenant_id=$($Config.tenant_id) `
    -var client_id=$($Config.client_id) `
    -var cluster_name=$($Config.cluster_name) `
    -var location=$($Config.location) `
    -var kubernetes_version=$($Config.kubernetes_version) `
    -var agent_count=$($Config.agent_count) `
    -var agent_vm_size=$($Config.agent_vm_size) `
    -var os_disk_size_GB=$($Config.os_disk_size_GB) `
    -var agent_max_pods=$($Config.agent_max_pods) `
    -var environment=$($Config.environment) 


 