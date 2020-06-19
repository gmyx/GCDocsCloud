variable "location" {
  type        = string
  description = "Azure region where the services will be deployed"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resoruce group using in current enviroment"
}

variable "app_object_id" {
  description = "The objectID of the application, not the client id"
}

variable "keyvault_name" {
  description = "The name of the keyvault"
}