resource "azurerm_resource_group" "resource1" {
  #resource group provided in sandbox
  name     = var.resource_group
  location = var.resource_group_location

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

data "template_cloudinit_config" "linuxconfig" {
  gzip=true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = "packages: ['nginx']"
  }
}

resource "tls_private_key" "linux_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "linuxkey" {
  filename = "linuxkey.pem"
  content = tls_private_key.linux_key.private_key_pem
  
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
  admin_username      = var.admin_name
  custom_data = data.template_cloudinit_config.linuxconfig.rendered
  availability_set_id = azurerm_availability_set.appset.id
  network_interface_ids = [
    azurerm_network_interface.networkinterface.id,
  ]
  admin_ssh_key {
    username=var.admin_name
    public_key=tls_private_key.linux_key.public_key_openssh
  }

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
  tls_private_key.linux_key
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
