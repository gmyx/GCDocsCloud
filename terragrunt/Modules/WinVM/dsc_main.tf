#process adapted from https://www.reddit.com/r/Terraform/comments/ct19q4/azure_vm_dsc_configuration/

#compile the mof - NOTE: Need a delete provitioner to remove the compiled MOF on destroy
#compile done here to allow passing custom vars and set a unique name
resource "null_resource" "compileMOF" {
  depends_on = [module.WinVM] #must run after VM is built

  #provisioner used to compile the DSC so it can be read in the next step
  provisioner "local-exec" {
    command = <<COMMAND
    .\installDSC.ps1 `
      -subscription_id "${var.subscription_id}" `
      -tenant_id "${var.tenant_id}" `
      -client_id "${var.client_id}" `
      -client_secret "${var.client_secret}" `
      -configName "${var.dsc_name}" `
      -automationAccountName "${var.dsc_account_name}" `
      -resourceGroupName "${var.resource_group_name}" `
      -customString "${var.cluster_name}"
COMMAND
    interpreter = ["PowerShell"] #, "-file"]
    working_dir = "DSCcompileScript"
  }
}

#note forecePullAndApply must be false, wont work otherwise
resource "azurerm_virtual_machine_extension" "dsc_extension" {
  name                        = "DSC"
  virtual_machine_id          = module.WinVM.vm.id
  publisher                   = "Microsoft.Powershell"
  type                        = "DSC"
  type_handler_version        = "2.8"
  auto_upgrade_minor_version  = true
  depends_on                  = [null_resource.compileMOF]
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