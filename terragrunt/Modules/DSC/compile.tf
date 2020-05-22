#compile the mof - NOTE: Need a delete provitioner to remove the compiled MOF on destroy
#compile done here to allow passing custom vars and set a unique name
/*resource "null_resource" "generateHash" {
  depends_on = [azurerm_automation_module.StorageDSC]

  triggers = {
    always_run = timestamp() #always check the hash
  }

  #genereate the hash, if the file changed, it will trigger compileMOF
  provisioner "local-exec" {
    command = ".\\generateHash.ps1"
    interpreter = ["PowerShell"]
    working_dir = "Source"
  }
}*/

resource "null_resource" "compileMOF" {
  #after dsc change, sha256 must be changed MANUALLY
  #depends_on = [null_resource.generateHash]
  depends_on = [azurerm_automation_module.StorageDSC]

  triggers = {
    #If hash changed, update compilation
    sha256 = file("./Source/GCDOCSDsc.sha256")
  }

  #provisioner used to compile the DSC so it can be read in the next step
  provisioner "local-exec" {
    command = <<COMMAND
    .\installDSC.ps1 `
      -subscription_id "${var.subscription_id}" `
      -tenant_id "${var.tenant_id}" `
      -client_id "${var.client_id}" `
      -client_secret "${var.client_secret}" `
      -configName "${azurerm_automation_dsc_configuration.GCDOCS-DSC.name}" `
      -automationAccountName "${var.automation_account_name}" `
      -resourceGroupName "${var.resource_group_name}" `
      -customString "${azurerm_automation_dsc_configuration.GCDOCS-DSC.name}"
COMMAND
    interpreter = ["PowerShell"] #, "-file"]
    working_dir = "DSCcompileScript"
  }
}