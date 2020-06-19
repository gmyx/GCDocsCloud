#hosts the common infrastructure for all Dev
#   e.g. resource group and KeyVault

locals {
  # Automatically load environment-level variables
  location_vars = read_terragrunt_config(find_in_parent_folders("location.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl.json","account.hcl.json"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl.json"))

  # Extract out common variables for reuse
  location = local.location_vars.locals.location
  subscription_id   = local.account_vars.locals.subscription_id
  app_object_id = local.account_vars.locals.app_object_id
  environment = local.environment_vars.locals.environment

  resource_group_name = local.environment_vars.locals.resource_group_name
  keyvault_name = local.environment_vars.locals.keyvault_name
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  #ideally a git server, but for testing, full local
  source = "../../../modules/keyvault"

  before_hook "importKeyVault" {
    #gcdocsinstallers
    commands     = ["apply", "plan"]
    #send to import powershell to intelegently import
    execute = ["PowerShell", "tfImport/tfImport.ps1",
      "-subscriptionid", local.subscription_id,
      "-resourcegroupname", local.resource_group_name,
      "-KeyVaultName", local.keyvault_name]
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
  resource_group_name = dependency.ResourceGroup.outputs.resource_group_name
  app_object_id = local.app_object_id
  keyvault_name = local.keyvault_name
}