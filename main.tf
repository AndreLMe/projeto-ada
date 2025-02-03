resource "azurerm_resource_group" "rg" {
  name     = "rg-projeto-modulo"
  location = "brazilsouth"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-projeto-modulo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks"

  default_node_pool {
    name       = "default"
    node_count = 1                  
    vm_size    = "Standard_B2s"     
  }

  identity {
    type = "SystemAssigned"         
  }

  azure_policy_enabled = false
}

# Azure Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = "kv-projeto-modulo"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Get", "List"]
  }
}

resource "azurerm_mssql_server" "sql" {
  name                         = "sql-projeto-modulo"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "SenhaForteServidor12@#"
}

resource "azurerm_mssql_database" "db" {
  name           = "db-projeto-modulo"
  server_id      = azurerm_mssql_server.sql.id
  sku_name       = "Basic" 
  max_size_gb    = 2
}

resource "azurerm_key_vault_secret" "db_connection" {
  name         = "db-connection-string"
  value        = "Server=tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.db.name};User ID=${azurerm_mssql_server.sql.administrator_login};Password=${azurerm_mssql_server.sql.administrator_login_password};Encrypt=true;"
  key_vault_id = azurerm_key_vault.kv.id
}

data "azurerm_client_config" "current" {}
