#process adapted from https://www.reddit.com/r/Terraform/comments/ct19q4/azure_vm_dsc_configuration/

#note forecePullAndApply must be false, wont work otherwise
resource "azurerm_virtual_machine_extension" "dsc_extension" {
  name                        = "DSC"
  virtual_machine_id          = module.WinVM.vm.id
  publisher                   = "Microsoft.Powershell"
  type                        = "DSC"
  type_handler_version        = "2.8"
  auto_upgrade_minor_version  = true
  depends_on                  = [module.WinVM]
  settings = <<SETTINGS
    {
      "wmfVersion": "latest",
      "privacy": {
        "dataCollection": "enable"
      },
      "advancedOptions": {
        "forcePullandApply": false
      },
      "configurationArguments": {
        "RegistrationUrl": "${var.dsc_server_endpoint}",
        "NodeConfigurationName": "${var.dsc_name}.localhost",
        "ConfigurationMode": "${var.dsc_mode}",
        "ConfigurationModeFrequencyMins": 15,
        "RefreshFrequencyMins": 30,
        "RebootNodeIfNeeded": true,
        "ActionAfterReboot": "ContinueConfiguration",
        "AllowModuleOverwrite": true
      }
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "configurationArguments": {
        "RegistrationKey": {
          "userName": "NOT_USED",
          "Password": "${var.dsc_access_key}"
        }
      }
    }
  PROTECTED_SETTINGS
}