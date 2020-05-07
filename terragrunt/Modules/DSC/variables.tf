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