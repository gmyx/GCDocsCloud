#attach it
/*resource "azurerm_virtual_machine_extension" "dsc_extension" {
  name                 = "Microsoft.Powershell.DSC"  
  virtual_machine_id   = module.WinVM.vm.id
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.77"
  auto_upgrade_minor_version = true
  depends_on           = [module.WinVM]
  
  #use default extension properties as mentioned here:
  #https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/dsc-template
  settings = <<SETTINGS_JSON
        {
            "configurationArguments": {
                "RegistrationUrl" : "${var.dsc_server_endpoint}",
                "NodeConfigurationName" : "GCDOCSDsc.localhost",
                "ConfigurationMode": "${var.dsc_mode}",
                "RefreshFrequencyMins": 30,
                "ConfigurationModeFrequencyMins": 15,
                "RebootNodeIfNeeded": false,
                "ActionAfterReboot": "continueConfiguration",
                "AllowModuleOverwrite": true
 
            }
        }
  SETTINGS_JSON
  protected_settings = <<PROTECTED_SETTINGS_JSON
    {
        "configurationArguments": {
                "RegistrationKey": {
                    "userName": "NOT_USED",
                    "Password": "${var.dsc_access_key}"
                }
        }
    }
  PROTECTED_SETTINGS_JSON
}*/