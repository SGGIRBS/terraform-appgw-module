variable "context_short_name" {
  description = "The context of the resource E.G Hub (Hub Services), Apps (Applications)"
}
variable "environment_short_name" {
  default     = "Dev"
  description = "Dev, Test, Prod etc"
}
variable "location" {
  default = "West Europe"
  description = "Which region to deploy the resources to"
}
variable "certificate_1_password" {
  description = "Leave blank to force a prompt to enter the certificate password"
}
variable "virtual_network_resource_group_name" {
  default = ""
  description = "Name of the existing virtual network resource group"
}
variable "virtual_network_name" {
  default = ""
  description = "name of the existing virtual network"
}
variable "gateway_subnet_address_prefix" {
  default = ""
  description = ""
}
variable "tags" {
  type = map
  default = {
    Owner = "Operations"
    ManagedBy = "Terraform"
  } 
}

