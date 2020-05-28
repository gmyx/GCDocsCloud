variable "storage_account_name" {
  type = string
  description = "The name of the storage account"
}

variable "storage_share_name" {
  type = string
  description = "The name of the file share in the storage account"
}

variable "location" {
  type        = string
  description = "Azure region where the services will be deployed"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resoruce group using in current enviroment"
}