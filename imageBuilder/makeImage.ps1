#adapted from https://github.com/danielsollondon/azvmimagebuilder/tree/master/quickquickstarts/1a_Creating_a_Custom_Win_Image_on_Existing_VNET
[CmdletBinding()]
param (
    [string]$resourceGroupName,
    [string]$location,
    [string]$imageName = "win2019image",
    [string]$vnetName,
    [string]$subnetName,
    [string]$nsgName,
    [switch]$SkipCleanup
)

Write-Output "Part 1 - Init"
Write-Output "* resourceGroupName: $resourceGroupName"
Write-Output "* location: $location"
Write-Output "* vnetName: $vnetName"
Write-Output "* subnetName: $subnetName"
Write-Output "* nsgName: $nsgName"

Set-StrictMode -Version 3

# Step 1: Import module
Import-Module Az.Accounts

# Step 2: get existing context
$currentAzContext = Get-AzContext

# get subscription, this will get your current subscription
$subscriptionID=$currentAzContext.Subscription.Id

# image distribution metadata reference name
$runOutputName= $imageName + "ro"

# image template name
$imageTemplateName= $imageName + "template3"

Write-Output "" #intentional blank line
Write-Output "Part 2 - Configure VirtualNetwork"
Write-Output "* Add NSG Rule"
#Add NSG rule to allow the AIB deployed Azure Load Balancer to communicate with the proxy VM
Try {
    $AzureNSG = Get-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroupName -ErrorAction Stop
} catch {
    #NSG does not exiwsts, create it
    write-verbose "***1: $($error[0]) ***"
    $AzureNSG = New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroupName -location $location

    start-sleep -seconds 2
}

Try {
    Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $AzureNSG -Name AzureImageBuilderAccess -ErrorAction Stop | Out-Null
} catch {
    write-verbose "***2: $($error[0]) ***"
    #rules does not exist, add it
    $Result = Get-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroupName  |
        Add-AzNetworkSecurityRuleConfig -Name AzureImageBuilderAccess -Description "Allow Image Builder Private Link Access to Proxy VM" -Access Allow -Protocol Tcp -Direction Inbound -Priority 400 -SourceAddressPrefix AzureLoadBalancer -SourcePortRange * -DestinationAddressPrefix VirtualNetwork -DestinationPortRange 60000-60001 |
        Set-AzNetworkSecurityGroup
}

#Disable Private Service Policy on subnet
Write-Output "* Disable Private Service Policy on subnet"
$virtualNetwork= Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
($virtualNetwork | Select -ExpandProperty subnets | Where-Object  {$_.Name -eq $subnetName} ).privateLinkServiceNetworkPolicies = "Disabled"
$virtualNetwork | Set-AzVirtualNetwork | Out-Null

###
#create SIG image definition

az sig image-definition create \
   -g $imageResourceGroup \
   --gallery-name $sigName \
   --gallery-image-definition $imageDefName \
   --publisher corpIT \
   --os-state Generalized \
   --offer myOffer \
   --sku 18.04-LTS \
   --os-type Linux
###

#get templates and modify
Write-Output "" #intentional blank line
Write-Output "Part 3 - Get Templates and Modify them"
mkdir templates -ErrorAction Ignore | out-null
$templateUrl="https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/1a_Creating_a_Custom_Win_Image_on_Existing_VNET/existingVNETWindows.json"
$templateFilePath = "existingVNETWindows.json"

$aibRoleNetworkingUrl="https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/12_Creating_AIB_Security_Roles/aibRoleNetworking.json"
$aibRoleNetworkingPath = "aibRoleNetworking.json"

$aibRoleImageCreationUrl="https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/12_Creating_AIB_Security_Roles/aibRoleImageCreation.json"
$aibRoleImageCreationPath = "aibRoleImageCreation.json"

# download configs
Write-Output "* Downloading templates"
Invoke-WebRequest -Uri $templateUrl -OutFile templates\$templateFilePath -UseBasicParsing
Invoke-WebRequest -Uri $aibRoleNetworkingUrl -OutFile templates\$aibRoleNetworkingPath -UseBasicParsing
Invoke-WebRequest -Uri $aibRoleImageCreationUrl -OutFile templates\$aibRoleImageCreationPath -UseBasicParsing

Write-Output "* Modifying image template"
# update AIB image config template
((Get-Content -path templates\$templateFilePath -Raw) -replace '<subscriptionID>',$subscriptionID) | Set-Content -Path templates\$templateFilePath
((Get-Content -path templates\$templateFilePath -Raw) -replace '<rgName>',$resourceGroupName) | Set-Content -Path templates\$templateFilePath
((Get-Content -path templates\$templateFilePath -Raw) -replace '<region>',$location) | Set-Content -Path templates\$templateFilePath
((Get-Content -path templates\$templateFilePath -Raw) -replace '<runOutputName>',$runOutputName) | Set-Content -Path templates\$templateFilePath
((Get-Content -path templates\$templateFilePath -Raw) -replace '<imageName>',$imageName) | Set-Content -Path templates\$templateFilePath

((Get-Content -path templates\$templateFilePath -Raw) -replace '<vnetName>',$vnetName) | Set-Content -Path templates\$templateFilePath
((Get-Content -path templates\$templateFilePath -Raw) -replace '<subnetName>',$subnetName) | Set-Content -Path templates\$templateFilePath
((Get-Content -path templates\$templateFilePath -Raw) -replace '<vnetRgName>',$resourceGroupName) | Set-Content -Path templates\$templateFilePath

#part 3b
# setup role def names, these need to be unique
$timeInt=[math]::round($(get-date -UFormat "%s"))
$imageRoleDefName="Azure Image Builder Image Def"+$timeInt
$networkRoleDefName="Azure Image Builder Network Def"+$timeInt
$idenityName="aibIdentity"+$timeInt

# create user identity
## Add AZ PS module to support AzUserAssignedIdentity
Import-Module -Name Az.ManagedServiceIdentity

# create identity
Write-Output "* Createing new identity $idenityName"
New-AzUserAssignedIdentity -ResourceGroupName $resourceGroupName -Name $idenityName | out-null

$idenityNameResourceId=$(Get-AzUserAssignedIdentity -ResourceGroupName $resourceGroupName -Name $idenityName).Id
$idenityNamePrincipalId=$(Get-AzUserAssignedIdentity -ResourceGroupName $resourceGroupName -Name $idenityName).PrincipalId

Write-Output "* Modifying other templates"
# update template with identity
((Get-Content -path templates\$templateFilePath -Raw) -replace '<imgBuilderId>',$idenityNameResourceId) | Set-Content -Path templates\$templateFilePath

# update the role defintion names
((Get-Content -path templates\$aibRoleImageCreationPath -Raw) -replace 'Azure Image Builder Service Image Creation Role',$imageRoleDefName) | Set-Content -Path templates\$aibRoleImageCreationPath
((Get-Content -path templates\$aibRoleNetworkingPath -Raw) -replace 'Azure Image Builder Service Networking Role',$networkRoleDefName) | Set-Content -Path templates\$aibRoleNetworkingPath

# update role definitions
((Get-Content -path templates\$aibRoleNetworkingPath -Raw) -replace '<subscriptionID>',$subscriptionID) | Set-Content -Path templates\$aibRoleNetworkingPath
((Get-Content -path templates\$aibRoleNetworkingPath -Raw) -replace '<vnetRgName>',$resourceGroupName) | Set-Content -Path templates\$aibRoleNetworkingPath

((Get-Content -path templates\$aibRoleImageCreationPath -Raw) -replace '<subscriptionID>',$subscriptionID) | Set-Content -Path templates\$aibRoleImageCreationPath
((Get-Content -path templates\$aibRoleImageCreationPath -Raw) -replace '<rgName>', $resourceGroupName) | Set-Content -Path templates\$aibRoleImageCreationPath

# create role definitions from role configurations examples, this avoids granting contributor to the SPN
Write-Output "* Creating new role definitions"
$RoleDefinition1 = New-AzRoleDefinition -InputFile  .\templates\aibRoleImageCreation.json
$RoleDefinition2 = New-AzRoleDefinition -InputFile  .\templates\aibRoleNetworking.json
write-verbose $RoleDefinition1

# grant role definition to image builder user identity
Write-Output "* Creating new role assigments"
$RoleAssignment1 = New-AzRoleAssignment -ObjectId $idenityNamePrincipalId -RoleDefinitionName $imageRoleDefName -Scope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName"
$RoleAssignment2 = New-AzRoleAssignment -ObjectId $idenityNamePrincipalId -RoleDefinitionName $networkRoleDefName -Scope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName"
write-verbose $RoleAssignment1

#wait for the resources to be completed
start-sleep -seconds 4 #arbitrary, but Azure is quick

#submit the template
$Deployment = New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile templates\$templateFilePath -api-version "2019-05-01-preview" -imageTemplateName $imageTemplateName -svclocation $location
write-verbose $Deployment

#get templates and modify
Write-Output "" #intentional blank line
Write-Output "Part 4 - Build Image"
Write-Output "* Submit request"
Invoke-AzResourceAction -ResourceName $imageTemplateName -ResourceGroupName $resourceGroupName -ResourceType Microsoft.VirtualMachineImages/imageTemplates -ApiVersion "2019-05-01-preview" -Action Run -Force

Write-Output "* Wait for completion"
#set up for monitoring
$azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)

### Get a token
$token = $profileClient.AcquireAccessToken($currentAzContext.Tenant.TenantId)
$accessToken=$token.AccessToken

$managementEp = $currentAzContext.Environment.ResourceManagerUrl

$urlBuildStatus = [System.String]::Format("{0}subscriptions/{1}/resourceGroups/$resourceGroupName/providers/Microsoft.VirtualMachineImages/imageTemplates/{2}?api-version=2019-05-01-preview", $managementEp, $currentAzContext.Subscription.Id,$imageTemplateName)

$buildStatusResult = Invoke-WebRequest -Method GET  -Uri $urlBuildStatus -UseBasicParsing -Headers  @{"Authorization"= ("Bearer " + $accessToken)} -ContentType application/json
$buildJsonStatus = $buildStatusResult.Content
$buildJsonStatus

if ($SkipCleanup -eq $true) {return} #done then

#clean uyp identity, role assigments and roles
Write-Output "" #intentional blank line
Write-Output "End: Clean up identity and roles"

## remove role assignments
Remove-AzRoleAssignment -inputObject $RoleAssignment1 #-ObjectId $RoleAssignment1 -RoleDefinitionName $imageRoleDefName -Scope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName"
Remove-AzRoleAssignment -inputObject $RoleAssignment2 #-ObjectId $idenityNamePrincipalId -RoleDefinitionName $networkRoleDefName -Scope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName"

## remove definitions
Remove-AzRoleDefinition -inputObject $RoleDefinition1 -Force #-Id $imageRoleDefObjId -Force
Remove-AzRoleDefinition -inputObject $RoleDefinition2 -Force #-Id $networkRoleObjId -Force

## remove identity
Remove-AzUserAssignedIdentity -ResourceID $idenityNameResourceId -force

# Get ResourceID of the Image Template
#$resTemplateId = Get-AzResource -ResourceName $imageTemplateName -ResourceGroupName $resourceGroupName -ResourceType Microsoft.VirtualMachineImages/imageTemplates -ApiVersion "2019-05-01-preview"

# Delete Image Template Artifact
#Remove-AzResource -ResourceId $resTemplateId.ResourceId -Force | out-null

# Remove the deployment template
#Remove-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name "existingVNETWindows" | out-null