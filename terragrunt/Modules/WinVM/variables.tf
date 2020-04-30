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

variable "keyvault_id" {
  #type       = unkown
  description = "The Id of the keyvault where the secrets will be stored"
}

variable "admin_secret" {
  type        = string
  description = "TEMP: the default VM password."
}

variable "cluster_name" {
  type        = string
  description = "The name of the OTCS cluster (the containing resource group and the cluster DNS prefix are also using this value)"
}

variable "role" {
  type        = string
  description = "The role of the Vm, this role is appended to names"
}

variable "size" {
  type        = string
  description = "The classical defenition of cluster size. Will be deprecatd with Terraform 0.13"
}

variable "vnet_name" {
  type        = string
  description = "The name of the vnet that this Vm will be a part of"
}

variable "subnet_name" {
  type        = string
  description = "The name of the subnet that this Vm will be a part of"
}

variable "load_balancer_backend_address_pools_ids" {
  type        = list
  description = "List of Load Balancer Backend Address Pool IDs references to which this VM belongs"
  default     = [[], [], [], [], [], [], [], [], [], [], [], []]
}

variable "lb_nat_rule_id" {
  description "The ID of the load balancer nat rule to attach to"
  default = null
}