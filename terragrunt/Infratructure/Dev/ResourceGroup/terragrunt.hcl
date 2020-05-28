#hosts the common infrastructure for all Dev
#   e.g. resource group and KeyVault
//skip = true
locals {
  # Automatically load environment-level variables
  location_vars = read_terragrunt_config(find_in_parent_folders("location.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  location = local.location_vars.locals.location
  environment = local.environment_vars.locals.environment
  resource_group_name = local.environment_vars.locals.resource_group_name
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  #ideally a git server, but for testing, full local
  source = "../../../modules/ResourceGroup"
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