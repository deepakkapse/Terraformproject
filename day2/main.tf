resource "azurerm_resource_group" "resource1" {
  #resource group provided in sandbox
  name     = "1-9a3900eb-playground-sandbox"
  location = "East US"

}


resource "azurerm_storage_account" "storage_account" {
  name                     = "terraformstore29"
  location                 = azurerm_resource_group.resource1.location
  account_tier             = "Standard"
  resource_group_name      = azurerm_resource_group.resource1.name
  account_replication_type = "LRS"  #local redundancy storage

}

# this is used to create a container called data
resource "azurerm_storage_container" "container1" {
  name="data"
  storage_account_name = "terraformstore29"
  container_access_type = "blob" 
  depends_on = [ azurerm_storage_account.storage_account ]
}

# this is used to upload file to container
resource "azurerm_storage_blob" "blob1" {
  name="sample1.txt"
  storage_account_name = "terraformstore29"
  storage_container_name = "data"
  type = "Block"
  source="sample.txt"
  depends_on = [ azurerm_storage_container.container1 ]
  
}