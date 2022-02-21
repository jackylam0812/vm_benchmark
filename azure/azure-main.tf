terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

#Configure the Azure Provider
provider "azurerm" { 
  features {}
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}

#Create Resource Group
resource "azurerm_resource_group" "azure-rg" {
  name = "terraform-rg-new"
  location = var.rg_location
}

#Create a virtual network
resource "azurerm_virtual_network" "azure-vnet" {
  name                = "terraform-vnet"
  resource_group_name = azurerm_resource_group.azure-rg.name
  location            = var.rg_location
  address_space       = [var.azure_vnet_cidr]
  tags = { 
    environment = "terraform"
  }
}

#Create a subnet
resource "azurerm_subnet" "azure-subnet" {
  name                 = "terraform-subnet"
  resource_group_name  = azurerm_resource_group.azure-rg.name
  virtual_network_name = azurerm_virtual_network.azure-vnet.name
  address_prefixes       = [var.azure_subnet_cidr]
}

#Create Security Group to access Web Server
resource "azurerm_network_security_group" "azure-web-nsg" {
  name                = "terraform-nsg"
  location            = azurerm_resource_group.azure-rg.location
  resource_group_name = azurerm_resource_group.azure-rg.name

  security_rule {
    name                       = "AllowSSH"
    description                = "Allow SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "terraform"
  }
}

#Associate the Web NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "azure-web-nsg-association" {
  subnet_id                 = azurerm_subnet.azure-subnet.id
  network_security_group_id = azurerm_network_security_group.azure-web-nsg.id
}

# ------Create VM01------
resource "azurerm_public_ip" "azure-ip-01" {
  name                = "terraform-ip-01"
  location            = azurerm_resource_group.azure-rg.location
  resource_group_name = azurerm_resource_group.azure-rg.name
  allocation_method   = "Static"
  
  tags = { 
    environment = "terraform"
  }
}

resource "azurerm_network_interface" "azure-nic-01" {
  name                      = "terraform-nic-01"
  location                  = azurerm_resource_group.azure-rg.location
  resource_group_name       = azurerm_resource_group.azure-rg.name

  ip_configuration {
    name                          = "internal-01"
    subnet_id                     = azurerm_subnet.azure-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azure-ip-01.id
  }

  tags = { 
    environment = "terraform"
  }
}

resource "azurerm_linux_virtual_machine" "azure-terraform-01" {
  name                  = "terraform-01"
  location              = azurerm_resource_group.azure-rg.location
  resource_group_name   = azurerm_resource_group.azure-rg.name
  size                  = var.vm01
  computer_name         = var.linux_vm_hostname
  admin_username        = var.linux_admin_user
  admin_password        = var.linux_admin_password
  custom_data           = base64encode(local.startup_script)
  priority              = "Spot"
  eviction_policy       = "Deallocate"
  network_interface_ids = [azurerm_network_interface.azure-nic-01.id]
  disable_password_authentication = false
 
  boot_diagnostics{

  } 

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 50
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = "terraform"
  }
}

# # ------Create VM02------
# resource "azurerm_public_ip" "azure-ip-02" {
#   name                = "terraform-ip-02"
#   location            = azurerm_resource_group.azure-rg.location
#   resource_group_name = azurerm_resource_group.azure-rg.name
#   allocation_method   = "Static"
  
#   tags = { 
#     environment = "terraform"
#   }
# }

# resource "azurerm_network_interface" "azure-nic-02" {
#   name                      = "terraform-nic-02"
#   location                  = azurerm_resource_group.azure-rg.location
#   resource_group_name       = azurerm_resource_group.azure-rg.name

#   ip_configuration {
#     name                          = "internal-02"
#     subnet_id                     = azurerm_subnet.azure-subnet.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.azure-ip-02.id
#   }

#   tags = { 
#     environment = "terraform"
#   }
# }

# resource "azurerm_linux_virtual_machine" "azure-terraform-02" {
#   name                  = "terraform-02"
#   location              = azurerm_resource_group.azure-rg.location
#   resource_group_name   = azurerm_resource_group.azure-rg.name
#   size                  = var.vm02
#   computer_name         = var.linux_vm_hostname
#   admin_username        = var.linux_admin_user
#   admin_password        = var.linux_admin_password
#   custom_data           = base64encode(local.startup_script)
#   priority              = "Spot"
#   eviction_policy       = "Deallocate"
#   network_interface_ids = [azurerm_network_interface.azure-nic-02.id]
#   disable_password_authentication = false
     
#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Premium_LRS"
#     disk_size_gb         = 50
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
#     version   = "latest"
#   }

#   tags = {
#     environment = "terraform"
#   }
# }
