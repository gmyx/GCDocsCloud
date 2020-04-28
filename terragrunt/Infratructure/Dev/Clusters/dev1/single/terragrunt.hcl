locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  location_vars = read_terragrunt_config(find_in_parent_folders("location.hcl"))
  cluster_vars = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))
  vmdata_vars = read_terragrunt_config("vmdata.hcl")
  admin_secret_vars = read_terragrunt_config("admin_secret.hcl")

  # Extract out common variables for reuse
  environment = local.environment_vars.locals.environment
  location = local.location_vars.locals.location
  cluster_name = local.cluster_vars.locals.cluster_name
  admin_secret = local.admin_secret_vars.locals.admin_secret
  role = local.vmdata_vars.locals.role
  size = local.vmdata_vars.locals.size
} 

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  #ideally a git server, but for testing, full local
  #source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-modules-example.git//asg-elb-service?ref=v0.1.0"
  source = "../../../../../Modules/WinVM"  

  # Before apply or plan, run "terraform init -no-color".
  before_hook "before_hook_1" {
    commands     = ["apply", "plan"]
    execute      = ["terraform", "init", "-no-color"]
  }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "ResourceGroup" {
  config_path = "../../../ResourceGroup"
}

dependency "Keyvault" {
  config_path = "../../../Keyvault"
}

dependency "Network" {
  config_path = "../../../Network"
}

inputs = {
  location = local.location  
  cluster_name = local.cluster_name
  resource_group_name = dependency.ResourceGroup.outputs.resource_group_name
  environment = local.environment
  keyvault_id = dependency.Keyvault.outputs.keyvault_id
  admin_secret = local.admin_secret
  role = local.role
  size = local.size
  vnet_name = dependency.Network.outputs.vnet_name
  subnet_name = dependency.Network.outputs.subnet_name
}