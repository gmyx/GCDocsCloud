variable "location" {
  type        = string
  description = "Azure region where the services will be deployed"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resoruce group using in current enviroment"
}

variable "automation_account_name" {
  type        = string
  description = "The name of the automation account which will host the DSC"
}

#installers storage
variable "storage_access_url" {
  type        = string
  description = "The URL to the file share where the installers are"
}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account where the file share is"
}

#fileshare user name is Azure/storeage_account_name, so not needed
/*variable "FileShareUserName" {
  type        = string
  description = "The username of the files share, usually: Azure/fileShareName"
}*/

variable "fileshare_accesskey" {
  type        = string
  description = "The Access Key (either primary or secondary) of the files share"
}

#azure account stuff
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