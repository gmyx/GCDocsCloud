#hosts the common infrastructure for all Dev
#   e.g. resource group and KeyVault

locals {
  # Automatically load environment-level variables
  location_vars = read_terragrunt_config(find_in_parent_folders("location.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl","account.hcl"))

  # Extract out common variables for reuse
  location = local.location_vars.locals.location
  subscription_id   = local.account_vars.locals.subscription_id

  #names used for the storage accounts
  storage_account_name = "gcdocsinstallers"
  storage_share_name = "gcdocsinstallers"

  #can't rely on dependency here, so load it from the env source file
  rgn = local.environment_vars.locals.resource_group_name
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  #ideally a git server, but for testing, full local
  source = "../../../modules/ColdStorage"

  before_hook "importStorage" {
    #gcdocsinstallers
    commands     = ["apply", "plan"]
    #send to import powershell to intelegently import
    execute = ["PowerShell", "tfImport/tfImport.ps1", "-SubscriptionID", local.subscription_id, "-ResourceGroupName", local.rgn, "-StorageAccountName", local.storage_account_name]
  }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "ResourceGroup" {
  config_path = "../ResourceGroup"
}

inputs = {
  location = local.location
  storage_account_name = local.storage_account_name
  storage_share_name = local.storage_share_name
  resource_group_name = dependency.ResourceGroup.outputs.resource_group_name
}