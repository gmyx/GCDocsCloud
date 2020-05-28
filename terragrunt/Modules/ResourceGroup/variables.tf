variable "location" {
  type        = string
  description = "Azure region where the services will be deployed"
}

variable "resource_group_name" {
  type = string
  description = "The name of the resoruce group to create / manage"
}

/*variable "environment" {
  type        = string
  description = "A short representation of the envrioment. Max 5 char. Ex: Dev, Qa, PProd, Prod"

  validation {
    condition     = length(var.environment) < 6
    error_message = "The envrioment variable must be 5 char or less."
  }
}*/