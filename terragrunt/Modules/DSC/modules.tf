#import DSC modules: StorageDSC: Used to init the data drives
#instructions to get URI: https://mcpmag.com/articles/2018/09/27/upload-powershell-gallery-module-to-azure.aspx
resource "azurerm_automation_module" "StorageDSC" {
  #Source: https://github.com/dsccommunity/StorageDsc
  name                    = "StorageDSC"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/StorageDsc/5.0.0"
  }
}

#ComputerManagementDsc.8.2.0 - Azure has 5.0 which dates from 1800s

/*** done via before hook since TF has no clue on the version,
  need to manually import the updated version ***/

resource "azurerm_automation_module" "ComputerManagementDsc" {
  #Source: https://github.com/dsccommunity/StorageDsc
  name                    = "ComputerManagementDsc"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/ComputerManagementDsc/8.2.0"
  }
}
