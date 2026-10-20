resource "azurecaf_name" "resource_group" {
  name          = var.resource_group_name
  resource_type = "azurerm_resource_group"
}

resource "azurecaf_name" "vnet" {
  name          = "network"
  resource_type = "azurerm_virtual_network"
}

resource "azurecaf_name" "vm_subnet" {
  name          = "vm"
  resource_type = "azurerm_subnet"
}

resource "azurecaf_name" "secondary_subnet" {
  name          = "secondary"
  resource_type = "azurerm_subnet"
}

resource "azurecaf_name" "nsg" {
  name          = "vm"
  resource_type = "azurerm_network_security_group"
}

resource "azurecaf_name" "public_ip" {
  name          = "vm"
  resource_type = "azurerm_public_ip"
}

resource "azurecaf_name" "nic" {
  name          = "vm"
  resource_type = "azurerm_network_interface"
}

resource "azurecaf_name" "vm" {
  name          = "linux"
  resource_type = "azurerm_linux_virtual_machine"
}

resource "azurerm_resource_group" "main" {
  name     = azurecaf_name.resource_group.result
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = azurecaf_name.vnet.result
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "vm" {
  name                 = azurecaf_name.vm_subnet.result
  address_prefixes     = [var.subnet1_prefix]
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
}

resource "azurerm_subnet" "secondary" {
  name                 = azurecaf_name.secondary_subnet.result
  address_prefixes     = [var.subnet2_prefix]
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
}

resource "azurerm_network_security_group" "vm" {
  name                = azurecaf_name.nsg.result
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowSSHFromConfiguredCIDR"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_allowed_cidr
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = azurerm_subnet.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

resource "azurerm_public_ip" "vm" {
  name                = azurecaf_name.public_ip.result
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [var.availability_zone]
}

resource "azurerm_network_interface" "vm" {
  name                = azurecaf_name.nic.result
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = azurecaf_name.vm.result
  computer_name                   = azurecaf_name.vm.result
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = false
  zone                            = var.availability_zone
  network_interface_ids           = [azurerm_network_interface.vm.id]
  admin_password                  = var.admin_password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}