#variable needed to plug in DSC
variable "subscription_id" {
  description = "The subscription id of the subscription"
}

variable "tenant_id" {
  description = "The tenant id of the service principle"
}

variable "client_id" {
  description = "The client id of the service principle"
}

variable "client_secret" {
  description = "The client secret used to authenticate the service principle"
}

variable "dsc_name" {
  description = "The name of the DSC configuration from before compilation"
}

variable "dsc_mode" {
  default     = "ApplyAndAutoCorrect"
  description = "The mode of the DSC monitoring"
}
variable "dsc_account_name" {
  default = ""
  description = "Azure Automation azurerm_automation_account name"
}
variable "dsc_server_endpoint" {
  default = ""
  description = "Azure Automation azurerm_automation_account endpoint URL"
}
variable "dsc_access_key" {
  default = ""
 description = "Azure Automation azurerm_automation_account access key"
}