#pull in the null provider to be used with local_Exec
provider null {
  version = "~> 1"
}

#adapted from https://www.reddit.com/r/Terraform/comments/ct19q4/azure_vm_dsc_configuration/

#load the ps1 for this environment


#create the dsc object
resource "azurerm_automation_dsc_configuration" "GCDOCS-DSC" {
  name                    = "GCDOCSDsc"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name

  content_embedded        = file("Source/dsc.ps1")
}