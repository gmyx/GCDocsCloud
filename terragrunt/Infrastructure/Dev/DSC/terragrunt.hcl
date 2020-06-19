#hosts the common infrastructure for all Dev
#   e.g. resource group and KeyVault

locals {
  # Automatically load environment-level variables
  location_vars = read_terragrunt_config(find_in_parent_folders("location.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl.json"))  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl.json","account.hcl.json"))
  account_secret_vars = read_terragrunt_config(find_in_parent_folders("account_secret.hcl.json","account.hcl.json"))

  # Extract the variables we need for easy access
  subscription_id   = local.account_vars.locals.subscription_id
  client_id         = local.account_vars.locals.client_id
  client_secret     = local.account_secret_vars.locals.client_secret
  tenant_id         = local.account_vars.locals.tenant_id

  # Extract out common variables for reuse
  location = local.location_vars.locals.location

  #can't rely on dependency here, so load it from the env source file
  resource_group_name = local.environment_vars.locals.resource_group_name
  automation_account_name = local.environment_vars.locals.automation_account_name
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  #ideally a git server, but for testing, full local
  source = "../../../modules/DSC"

  #use a before hook to update hash file
  before_hook "updateHash" {
    commands     = ["apply", "plan"]
    execute      = ["PowerShell", "source/generateHash.ps1"]
  }

  before_hook "importDSC" {
    #gcdocsinstallers
    commands     = ["apply", "plan"]
    #send to import powershell to intelegently import
    execute = ["PowerShell", "tfImport/tfImport.ps1",
      "-SubscriptionID", local.subscription_id,
      "-clientID", local.client_id,
      "-clientSecret", local.client_secret,
      "-tenantID", local.tenant_id,
      "-resourceGroupName", local.resource_group_name,
      "-automationAccountName", local.automation_account_name]
  }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "ResourceGroup" {
  config_path = "../ResourceGroup"
}

dependency "AutomationAccount" {
  config_path = "../AutomationAccount"
}

dependency "ColdStorage" {
  config_path = "../ColdStorage"
}

inputs = {
  location = local.location
  resource_group_name = dependency.ResourceGroup.outputs.resource_group_name
  automation_account_name = dependency.AutomationAccount.outputs.automation_account_name
  storage_access_url = dependency.ColdStorage.outputs.primary_file_endpoint
  storage_account_name = dependency.ColdStorage.outputs.coldstorage_name
  fileshare_accesskey = dependency.ColdStorage.outputs.primary_access_key
  subscription_id   = local.subscription_id
  client_id         = local.client_id
  client_secret     = local.client_secret
  tenant_id         = local.tenant_id
}