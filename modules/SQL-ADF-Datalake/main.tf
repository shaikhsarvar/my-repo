
resource "azurerm_mssql_server" "sql" {
  name                = var.sql_server_name
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = "12.0"
  administrator_login = var.sql_admin_username
  #check password in tfvars
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_database" "db" {
  name      = var.sql_database_name
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "Basic"

  max_size_gb = 2
}

data "http" "my_public_ip" {
  url = "https://api.ipify.org"
}

resource "azurerm_mssql_firewall_rule" "client_ip" {
  name             = "Allow-Terraform-Client-IP"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = trimspace(data.http.my_public_ip.response_body)
  end_ip_address   = trimspace(data.http.my_public_ip.response_body)
}


resource "azurerm_storage_account" "adls" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true

  min_tls_version = "TLS1_2"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "raw" {
  name               = var.adls_filesystem_name
  storage_account_id = azurerm_storage_account.adls.id
}

resource "azurerm_data_factory" "adf" {
  name                = var.data_factory_name
  resource_group_name = var.resource_group_name
  location            = var.location

  managed_virtual_network_enabled = true

  identity {
    type = "SystemAssigned"
  }
}

#need acces of useraccess administrator to perfom
#resource "azurerm_role_assignment" "adf_storage" {
# scope                = azurerm_storage_account.adls.id
#role_definition_name = "Storage Blob Data Contributor"
#principal_id         = azurerm_data_factory.adf.identity[0].principal_id
#}
