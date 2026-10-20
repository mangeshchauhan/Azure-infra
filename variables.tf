variable "subscription_id" {
  description = "Azure subscription ID used by the AzureRM provider."
  type        = string
}

variable "location" {
  description = "Azure region for the resources."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Base name for the resource group."
  type        = string
  default     = "network-vm"
}

variable "vm_size" {
  description = "Azure VM size. Confirm availability for the selected region and zone."
  type        = string
  default     = "Standard_B2s"
}

variable "availability_zone" {
  description = "Availability zone for the virtual machine and its public IP."
  type        = string
  default     = "1"
}

variable "admin_username" {
  description = "Linux administrator account name."
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Password for the Linux administrator account. Supply through TF_VAR_admin_password."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.admin_password) >= 12 && length(var.admin_password) <= 72
    error_message = "admin_password must be between 12 and 72 characters."
  }
}

variable "ssh_allowed_cidr" {
  description = "Source CIDR allowed to connect to SSH, such as your public IP followed by /32."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0))
    error_message = "ssh_allowed_cidr must be a valid IPv4 or IPv6 CIDR range."
  }
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet1_prefix" {
  description = "Address prefix for the VM subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet2_prefix" {
  description = "Address prefix for the additional subnet."
  type        = string
  default     = "10.0.2.0/24"
}