# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
#
# adapted from examples found at https://github.com/gruntwork-io/terragrunt-infrastructure-live-example
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl","account.hcl"))
  account_secret_vars = read_terragrunt_config(find_in_parent_folders("account_secret.hcl","account.hcl"))

  # Extract the variables we need for easy access
  subscription_id   = local.account_vars.locals.subscription_id
  client_id         = local.account_vars.locals.client_id
  client_secret     = local.account_secret_vars.locals.client_secret
  tenant_id         = local.account_vars.locals.tenant_id

}

terraform {
  extra_arguments "retry_lock" {
    commands  = ["plan", "apply", "validate", "version", "init"] #get_terraform_commands_that_need_vars()
    #arguments = ["-no-color"]
  }
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  # Preventing automatic upgrades to new versions that may contain breaking changes.
  # Any non-beta version >= 1.27.0 and < 2.0.0
  version = "~>2.6"

  subscription_id = "${local.subscription_id}"
  client_id       = "${local.client_id}"
  client_secret   = "${local.client_secret}"
  tenant_id       = "${local.tenant_id}"

  features {
    key_vault {
      purge_soft_delete_on_destroy = false
      recover_soft_deleted_key_vaults = true
    }
  }
}
EOF
}