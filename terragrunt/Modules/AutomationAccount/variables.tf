variable "location" {
  type        = string
  description = "Azure region where the services will be deployed"
}

variable "automation_account_name" {
  type        = string
  description = "The name of the account to create / manage"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resoruce group using in current enviroment"
}