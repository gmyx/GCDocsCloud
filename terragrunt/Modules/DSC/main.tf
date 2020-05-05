#pull in the null provider to be used with local_Exec
provider null {
  version = "~> 1"
}

#create the dsc object
resource "azurerm_automation_dsc_configuration" "GCDOCS-DSC" {
  name                    = "GCDOCSDsc"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name

  content_embedded        = file("Source/dsc.ps1")
}

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
}