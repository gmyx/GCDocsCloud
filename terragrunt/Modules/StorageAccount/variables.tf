variable "location" {
  type        = string
  description = "Azure region where the services will be deployed"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resoruce group using in current enviroment"
}

variable "environment" {
  type        = string
  description = "A short representation of the envrioment. Max 5 char. Ex: Dev, Qa, PProd, Prod"
}