[CmdletBinding()]
Param (
    [string]$ConfigFile = $(Throw "ConfigFile is required")
)

$Config = Import-PowerShellDataFile -Path $ConfigFile

$SecurePassword = ConvertTo-SecureString -String $Config.client_secret -AsPlainText -Force
$SPCredential = [pscredential]::new($Config.client_id, $SecurePassword)
Connect-AzAccount -ServicePrincipal -Credential $SPCredential -Tenant $Config.tenant_id | Out-Null

& terraform destroy -var subscription_id=$($Config.subscription_id) `
    -var client_secret=$($Config.client_secret) `
    -var tenant_id=$($Config.tenant_id) `
    -var client_id=$($Config.client_id) `
    -var location=$($Config.location) `
    -var admin_secret=$($Config.admin_secret)