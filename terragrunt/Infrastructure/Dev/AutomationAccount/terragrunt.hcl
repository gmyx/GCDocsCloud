#hosts the common infrastructure for all Dev
#   e.g. resource group and KeyVault

locals {
  # Automatically load environment-level variables
  location_vars = read_terragrunt_config(find_in_parent_folders("location.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  location = local.location_vars.locals.location
  automation_account_name = local.environment_vars.locals.automation_account_name
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  #ideally a git server, but for testing, full local
  source = "../../../modules/AutomationAccount"
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
  automation_account_name = local.automation_account_name
  resource_group_name = dependency.ResourceGroup.outputs.resource_group_name
}