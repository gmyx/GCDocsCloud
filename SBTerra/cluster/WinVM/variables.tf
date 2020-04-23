variable "location" {
  description = "Location of VM"
  default     = "canadacentral"
}

variable "resource_group_name" {
  description = "Name of the resourcegroup that will contain the VM resources"
}

variable "role" {
  description = "The role of the Vm, this role is appended to names"
}

variable "keyvault_id" {
  description = "They id of the keyvault where the secrets will be stored"
}

variable "environment" {
  description = "The type of environment this cluster is for. Some policies may apply only to 'Production' environments."
}

variable "cluster_name" {
  description = "The name of the OTCS cluster (the containing resource group and the cluster DNS prefix are also using this value)"
}

variable "admin_secret" {
  description = "The default windows admin password that will be used"
}

variable "vnet_name" {
  description = "The name of the vnet that this Vm will be a part of"
}

variable "subnet_name" {
  description = "The name of the subnet that this Vm will be a part of"
}

variable "vm_size" {
  description = "The VM size for the cluster nodes"
  default = "Standard_D4s_v3"
}