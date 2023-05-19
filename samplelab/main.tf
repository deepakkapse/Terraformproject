resource "azurerm_resource_group" "resource1" {
  #resource group provided in sandbox
  name     = "1-c57f7fa3-playground-sandbox"
  location = "West US"

}

resource "azurerm_storage_account" "storage" {
  name                     = "dk29kapse"
  location                 = azurerm_resource_group.resource1.location
  account_tier             = "Standard"
  resource_group_name      = azurerm_resource_group.resource1.name
  account_replication_type = "LRS"  #local redundancy storage

}
