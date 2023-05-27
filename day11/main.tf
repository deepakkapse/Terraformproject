resource "azurerm_resource_group" "resource1" {
  name     = "1-9eca02f0-playground-sandbox"
  location = "South Central US"
}

resource "azurerm_service_plan" "appserviceplan" {
  name                = "appservice-plan"
  resource_group_name = azurerm_resource_group.resource1.name
  location            = azurerm_resource_group.resource1.location
  os_type             = "Windows"
  sku_name            = "F1"
}

resource "azurerm_mssql_server" "app_server" {
  name                         = "appserver2908"
  resource_group_name          = azurerm_resource_group.resource1.name
  location                     = azurerm_resource_group.resource1.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "SQL@1234"
}

resource "azurerm_mssql_database" "app_db" {
  name                = "appdb1"
  server_id           = azurerm_mssql_server.app_server.id
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb         = 5
  read_scale          = false
  zone_redundant      = false
  create_mode         = "Default"



  tags = {
    Environment = "Production"
    Project     = "MyApp"
  }
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
resource "azurerm_mssql_firewall_rule" "firewall1" {
  name             = "FirewallRule1"
  server_id        = azurerm_mssql_server.app_server.id
  start_ip_address = "203.192.241.91"
  end_ip_address   = "203.192.241.91"
}


output "database_id" {
  value = azurerm_mssql_database.app_db.id
}

output "weburl" {
  value = "https://${azurerm_windows_web_app.webapp.default_hostname}"
}

