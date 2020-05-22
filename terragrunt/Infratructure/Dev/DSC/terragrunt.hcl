#hosts the common infrastructure for all Dev
#   e.g. resource group and KeyVault

locals {
  # Automatically load environment-level variables
  location_vars = read_terragrunt_config(find_in_parent_folders("location.hcl"))
  //environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl","account.hcl"))
  account_secret_vars = read_terragrunt_config(find_in_parent_folders("account_secret.hcl","account.hcl"))

  # Extract the variables we need for easy access
  subscription_id   = local.account_vars.locals.subscription_id
  client_id         = local.account_vars.locals.client_id
  client_secret     = local.account_secret_vars.locals.client_secret
  tenant_id         = local.account_vars.locals.tenant_id

  # Extract out common variables for reuse
  location = local.location_vars.locals.location
  //environment = local.environment_vars.locals.environment
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

inputs = {
  location = local.location
  resource_group_name = dependency.ResourceGroup.outputs.resource_group_name
  automation_account_name = dependency.AutomationAccount.outputs.automation_account_name
  subscription_id   = local.subscription_id
  client_id         = local.client_id
  client_secret     = local.client_secret
  tenant_id         = local.tenant_id
}