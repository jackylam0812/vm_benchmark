# azure-variables.tf | Variables for the Azure module

# Location Resource Group
variable "rg_location" {
  type        = string
  description = "Location of Resource Group"
  default     = "West US 2"
}

# Vnet CIDR
variable "azure_vnet_cidr" {
  type        = string
  description = "Vnet CIDR"
  default     = "10.2.0.0/16"
}

# Subnet CIDR
variable "azure_subnet_cidr" {
  type        = string
  description = "Subnet CIDR"
  default     = "10.2.1.0/24"
}

# Linux VM Admin User
variable "linux_admin_user" {
  type        = string
  description = "Linux VM Admin User"
  default     = "azureuser"
}

# Linux VM Admin Password
variable "linux_admin_password" {
  type        = string
  description = "Linux VM Admin Password"
  default     = "Azure@2022"
}

# Linux VM Hostname
variable "linux_vm_hostname" {
  type        = string
  description = "Linux VM Hostname"
  default     = "tfbenchmark"
}

# Linux Publisher used to build VMs
variable "linux-publisher" {
  type        = string
  description = "Linux Publisher used to build VMs"
  default     = "Canonical"
}

# Linux Offer used to build VMs
variable "linux-offer" {
  type        = string
  description = "Linux Offer used to build VMs"
  default     = "UbuntuServer"
}

# Linux SKU used to build VMs
variable "linux-sku" {
  type        = string
  description = "Linux Server SKU used to build VMs"
  default     = "18.04-LTS"
}

# VM01 Type
variable "vm01"{
  type        = string
  description = "VM Type for VM01"
  default     = "Standard_D4s_v5"
}

# VM02 Type
variable "vm02"{
  type        = string
  description = "VM Type for VM02"
  default     = "Standard_D4s_v4"
}
