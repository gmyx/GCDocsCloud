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