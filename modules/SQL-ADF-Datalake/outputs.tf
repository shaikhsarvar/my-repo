output "resource_group_name" {
  value = var.resource_group_name
}

output "azure_region" {
  value = var.location
}

output "sql_server_name" {
  value = azurerm_mssql_server.sql.name
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.sql.fully_qualified_domain_name
}

output "sql_database_name" {
  value = azurerm_mssql_database.db.name
}

output "sql_database_id" {
  value = azurerm_mssql_database.db.id
}

output "storage_account_name" {
  value = azurerm_storage_account.adls.name
}

output "storage_account_id" {
  value = azurerm_storage_account.adls.id
}

output "adls_filesystem_name" {
  value = azurerm_storage_data_lake_gen2_filesystem.raw.name
}

output "adls_filesystem_id" {
  value = azurerm_storage_data_lake_gen2_filesystem.raw.id
}

output "data_factory_name" {
  value = azurerm_data_factory.adf.name
}

output "data_factory_id" {
  value = azurerm_data_factory.adf.id
}

output "data_factory_principal_id" {
  value = azurerm_data_factory.adf.identity[0].principal_id
}
