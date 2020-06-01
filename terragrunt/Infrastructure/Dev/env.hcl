# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  environment = "dev"
  resource_group_name = "GCDOCS-dev-rg" #hard codded, it is assigned
  automation_account_name = "GCDOCS-DSC"
}
