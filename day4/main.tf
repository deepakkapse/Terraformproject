resource "azurerm_resource_group" "resource1" {
  #resource group provided in sandbox
  name     = var.resource_group
  location = var.resource_group_location

}


resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_accountname
  location                 = azurerm_resource_group.resource1.location
  account_tier             = "Standard"
  resource_group_name      = azurerm_resource_group.resource1.name
  account_replication_type = "LRS" #local redundancy storage

}

# this is used to create a container called data
resource "azurerm_storage_container" "container1" {
  name                  = "data"
  storage_account_name  = var.storage_accountname
  container_access_type = "blob"
  depends_on            = [azurerm_storage_account.storage_account]
}

# this is used to upload file to container
resource "azurerm_storage_blob" "blob1" {
  name                   = "sample1.txt"
  storage_account_name   = var.storage_accountname
  storage_container_name = "data"
  type                   = "Block"
  source                 = "sample.txt"
  depends_on             = [azurerm_storage_container.container1]

}

data "azurerm_subnet" "subnetA" {
  name= "subnet1"
  virtual_network_name="sandbox-vmnet"
  resource_group_name=var.resource_group
  depends_on = [
    azurerm_virtual_network.vmnet
  ]
}


# This is used to create virtual network
resource "azurerm_virtual_network" "vmnet" {
  name                = "sandbox-vmnet"
  location            = azurerm_resource_group.resource1.location
  resource_group_name = azurerm_resource_group.resource1.name
  address_space       = ["10.0.0.0/16"]


  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  tags = {
    environment = "Test"
  }
}

resource "azurerm_network_interface" "networkinterface" {
  name                = "vm-nic"
  location            = var.resource_group_location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnetA.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "Os" {
  name                = "vm-machine"
  resource_group_name = var.resource_group
  location            = var.resource_group_location
  size                = "Standard_D2s_v3"
  admin_username      = var.admin_name
  admin_password      = var.admin_pass
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.networkinterface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
 
  }
  depends_on=[
  azurerm_network_interface.networkinterface
 ]
}