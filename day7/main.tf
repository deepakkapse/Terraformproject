resource "azurerm_resource_group" "resource1" {
  #resource group provided in sandbox
  name     = var.resource_group
  location = var.resource_group_location

}
#secret key vault usage
data "azurerm_client_config" "current" {

}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}



/*
resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_accountname
  location                 = azurerm_resource_group.resource1.location
  account_tier             = "Standard"
  resource_group_name      = azurerm_resource_group.resource1.name
  account_replication_type = "LRS" #local redundancy storage

}
*/

/*
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

*/



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

data "azurerm_subnet" "subnetA" {
  name= "subnet1"
  virtual_network_name="sandbox-vmnet"
  resource_group_name=var.resource_group
  depends_on = [
    azurerm_virtual_network.vmnet
  ]
}

resource "azurerm_network_interface" "networkinterface" {
  name                = "vm-nic"
  location            = var.resource_group_location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnetA.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.publicip.id

  }
  depends_on = [ 
    azurerm_virtual_network.vmnet,
    azurerm_public_ip.publicip
   ]
  lifecycle {
    create_before_destroy = true
  }
}

#create security group
resource "azurerm_network_security_group" "nsg" {
  name                = "my-nsg"
  location            = var.resource_group_location
  resource_group_name = var.resource_group
}


/*
#to get ip address in linux
locals {
  my_ip = cidrhost(data.external.my_ip.result, 0)
}

data "external" "my_ip" {
  program = ["sh", "-c", "curl -sS ifconfig.me"]
}
*/




#create inbound rule for ssh
resource "azurerm_network_security_rule" "nsg_rule_ssh" {
  name                        = "allow-ssh"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes      = ["203.192.204.50"]
  destination_address_prefixes = ["0.0.0.0/0"]

  resource_group_name           = var.resource_group
  network_security_group_name   = azurerm_network_security_group.nsg.name
}
#allow inbound rule for rdp
resource "azurerm_network_security_rule" "nsg_rule_rdp" {
  name                        = "allow-rdp"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefixes      = ["203.192.204.50"]
  destination_address_prefixes = ["0.0.0.0/0"]

  resource_group_name           = var.resource_group
  network_security_group_name   = azurerm_network_security_group.nsg.name
}


#create a public ip address
resource "azurerm_public_ip" "publicip" {
  name                = "public_ip1"
  resource_group_name = var.resource_group
  location            = var.resource_group_location
  allocation_method   = "Static"
}
resource "azurerm_linux_virtual_machine" "Os" {
  name                = "vm-machine"
  resource_group_name = var.resource_group
  location            = var.resource_group_location
  size                = "Standard_D2s_v3"
  admin_username      = "vm_machine"
  admin_password      = azurerm_key_vault_secret.vmpassword.value
  disable_password_authentication = false
  availability_set_id = azurerm_availability_set.appset.id
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
  azurerm_network_interface.networkinterface,
  azurerm_availability_set.appset, 
  azurerm_key_vault_secret.vmpassword
 ]
}

resource "azurerm_managed_disk" "data_disk" {
  name                 = "data-disk1"
  location             = var.resource_group_location
  resource_group_name  = var.resource_group
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

resource "azurerm_virtual_machine_data_disk_attachment" "attachdisk" {
  managed_disk_id    = azurerm_managed_disk.data_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.Os.id
  lun                = "10"
  caching            = "ReadWrite"
  depends_on = [ azurerm_linux_virtual_machine.Os,
  azurerm_managed_disk.data_disk
   ]
}

resource "azurerm_availability_set" "appset" {
  name                = "example-aset"
  location            = var.resource_group_location
  resource_group_name = var.resource_group
  platform_fault_domain_count = 3
  platform_update_domain_count = 3
  depends_on = [ azurerm_virtual_network.vmnet,
   ]
}


resource "azurerm_key_vault" "app_vault" {
  name                        = "vault2908"
  location                    = var.resource_group_location
  resource_group_name         = var.resource_group
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
  depends_on = [ azurerm_resource_group.resource1 ]
}

resource "azurerm_key_vault_secret" "vmpassword" {
  name="vmpassword"
  value = "Azure@123"
   key_vault_id = azurerm_key_vault.app_vault.id
   depends_on = [ azurerm_key_vault.app_vault ]

}