#variable needed to plug in DSC
variable "dsc_name" {
  description = "The name of the DSC configuration from before compilation"
}

variable "dsc_mode" {
  default     = "ApplyAndAutoCorrect"
  description = "The mode of the DSC monitoring"
}

variable "dsc_server_endpoint" {
  default = ""
  description = "Azure Automation azurerm_automation_account endpoint URL"
}
variable "dsc_access_key" {
  default = ""
 description = "Azure Automation azurerm_automation_account access key"
}