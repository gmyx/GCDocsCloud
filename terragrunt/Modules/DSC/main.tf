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

#import DSC modules: None yet

#compile the mof - NOTE: Need a delete provitioner to remove the compiled MOF on destroy
resource "null_resource" "compileMOF" {
  #not sure on triggers
  /*triggers = {
    #this should force this resource to run everytime
    always_run = timestamp()
  }*/

  #provisioner used to compile the DSC so it can be read in the next step
  #TODO: Find a way to mask the client secret. Write it to file?
  provisioner "local-exec" {
    command = ".\\installDSC.ps1 -subscription_id \"${var.subscription_id}\" -tenant_id \"${var.tenant_id}\" -client_id \"${var.client_id}\" -client_secret \"${var.client_secret}\" -configName \"${azurerm_automation_dsc_configuration.GCDOCS-DSC.name}\" -automationAccountName \"${var.automation_account_name}\" -resourceGroupName \"${var.resource_group_name}\""
    interpreter = ["PowerShell"] #, "-file"]
    working_dir = "compileScript"
  }
}

/* old code below - will be removed if this process works as expected
#run a script to compile
resource "null_resource" "compileMOF" {
  triggers = {
    #this should force this resource to run everytime
    always_run = timestamp()
  }

  #provisioner used to compile the DSC so it can be read in the next step
  provisioner "local-exec" {
    command = "compile.ps1"
    interpreter = ["PowerShell", "-file"]
    working_dir = "Source"
  }
}

#compile it
resource "azurerm_automation_dsc_nodeconfiguration" "GCDOCSDSCNode" {
  name                    = "GCDOCSDsc.localhost"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  depends_on              = [azurerm_automation_dsc_configuration.GCDOCS-DSC, null_resource.compileMOF]

  content_embedded        = file("Source/GCDOCSDsc/localhost.mof")
}*/