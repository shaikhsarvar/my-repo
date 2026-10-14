
# ADF Managed Private Endpoint to ADLS Gen2 DFS

resource "azurerm_data_factory_managed_private_endpoint" "adls_dfs" {
  name               = "mpe-adls-dfs-ci"
  data_factory_id    = azurerm_data_factory.adf.id
  target_resource_id = azurerm_storage_account.adls.id
  subresource_name   = "dfs"
}
