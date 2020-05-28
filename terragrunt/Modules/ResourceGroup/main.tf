terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  # The latest version of Terragrunt (v0.19.0 and above) requires Terraform 0.12.0 or above.
  required_version = "~> 0.12.17"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    azurerm = {
      version = "~> 2.6"
    }
  }

  experiments = [variable_validation]
}

resource "azurerm_resource_group" "GCDOCS" {
  name     = var.resource_group_name   #"GCDOCS-${var.environment}-rg"
  location = var.location

  lifecycle {
    prevent_destroy = true
  }
}