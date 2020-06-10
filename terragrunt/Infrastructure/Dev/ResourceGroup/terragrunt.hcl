#hosts the common infrastructure for all Dev
#   e.g. resource group and KeyVault
//skip = true
locals {
  # Automatically load environment-level variables
  location_vars = read_terragrunt_config(find_in_parent_folders("location.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl.json"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl.json","account.hcl.json"))

  # Extract out common variables for reuse
  subscription_id   = local.account_vars.locals.subscription_id
  location = local.location_vars.locals.location
  environment = local.environment_vars.locals.environment

  #can't rely on dependency here, so load it from the env source file
  resource_group_name = local.environment_vars.locals.resource_group_name
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  #ideally a git server, but for testing, full local
  source = "../../../modules/ResourceGroup"

  before_hook "importRG" {
    #gcdocsinstallers
    commands     = ["apply", "plan"]
    #send to import powershell to intelegently import
    execute = ["PowerShell", "tfImport/tfImport.ps1", "-SubscriptionID", local.subscription_id, "-ResourceGroupName", local.resource_group_name]
  }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  location = local.location
  #environment = local.environment
  resource_group_name = local.resource_group_name
}