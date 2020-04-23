variable "subscription_id" {
  description = "The ID of the Azure subscription where the OTCS system will be deployed"
}

variable "client_secret" {
  description = "The password of the Service Principal used by Terraform to access Azure"
}

variable "tenant_id" {
  description = "The ID of the Azure AD tenant where the Terraform Service Principal lives"
}

variable "client_id" {
  description = "The application ID of the Service Principal used by Terraform to access Azure"
}

variable "location" {
  description = "Azure region where the OTCS cluster will be deployed"
}

variable "admin_secret" {
  description = "The default windows admin password that will be used"
}