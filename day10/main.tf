resource "azurerm_resource_group" "resource1" {
  #resource group provided in sandbox
  name     = "1-74a7cb73-playground-sandbox"
  location = "East US"

}

resource "azurerm_service_plan" "appserviceplan" {
  name                = "appservice-plan"
  resource_group_name = azurerm_resource_group.resource1.name
  location            = azurerm_resource_group.resource1.location
  os_type             = "Windows"
  sku_name            = "F1"
  
}

resource "azurerm_windows_web_app" "webapp" {
  name                = "windows-web-app29"
  resource_group_name = azurerm_resource_group.resource1.name
  location            = azurerm_resource_group.resource1.location
  service_plan_id     = azurerm_service_plan.appserviceplan.id

  site_config {
    always_on = false

  }
}

output "weburl" {
  value = "https://${azurerm_windows_web_app.webapp.default_hostname}"
  
}

