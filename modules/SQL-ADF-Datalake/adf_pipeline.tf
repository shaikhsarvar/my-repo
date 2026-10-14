
# ------------------------------------------
# 1. SQL Database Linked Service
# ------------------------------------------
resource "azurerm_data_factory_linked_service_azure_sql_database" "sql" {
  name            = "LS_AzureSQL"
  data_factory_id = azurerm_data_factory.adf.id

  connection_string = "Data Source=tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.db.name};User ID=${var.sql_admin_username};Password=${var.sql_admin_password};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}

# ------------------------------------------
# 2. ADLS Gen2 Linked Service
# ------------------------------------------
resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "adls" {
  name                 = "LS_ADLSGen2"
  data_factory_id      = azurerm_data_factory.adf.id
  url                  = "https://${azurerm_storage_account.adls.name}.dfs.core.windows.net"
  use_managed_identity = true

}

# ------------------------------------------
# 3. SQL Source Dataset
# ------------------------------------------
resource "azurerm_data_factory_dataset_azure_sql_table" "employee" {
  name              = "DS_SQL_Employee"
  data_factory_id   = azurerm_data_factory.adf.id
  linked_service_id = azurerm_data_factory_linked_service_azure_sql_database.sql.id

  schema = var.sql_schema_name
  table  = var.sql_table_name
}

# ------------------------------------------
# 4. ADLS Gen2 Destination Dataset
# ------------------------------------------
resource "azurerm_data_factory_dataset_delimited_text" "employee_csv" {
  name                = "DS_ADLS_Employee_CSV"
  data_factory_id     = azurerm_data_factory.adf.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.adls.name

  azure_blob_fs_location {
    file_system = azurerm_storage_data_lake_gen2_filesystem.raw.name
    path        = "output"
    filename    = var.adls_output_file
  }

  column_delimiter    = ","
  encoding            = "UTF-8"
  first_row_as_header = true
}

# ------------------------------------------
# 5. Copy Pipeline: SQL to ADLS Gen2
# ------------------------------------------
resource "azurerm_data_factory_pipeline" "copy_employee" {
  name            = "PL_Copy_Employee_SQL_to_ADLS"
  data_factory_id = azurerm_data_factory.adf.id
  description     = "Copy dbo.Employee from Azure SQL Database to ADLS Gen2 as CSV."

  activities_json = jsonencode([
    {
      name = "CopyEmployeeToADLS"
      type = "Copy"

      dependsOn = []
      policy = {
        timeout                = "0.01:00:00"
        retry                  = 1
        retryIntervalInSeconds = 30
        secureInput            = false
        secureOutput           = false
      }
      userProperties = []

      typeProperties = {
        source = {
          type           = "AzureSqlSource"
          sqlReaderQuery = "SELECT * FROM ${var.sql_schema_name}.${var.sql_table_name}"
        }

        sink = {
          type = "DelimitedTextSink"

          storeSettings = {
            type = "AzureBlobFSWriteSettings"
          }

          formatSettings = {
            type         = "DelimitedTextWriteSettings"
            quoteAllText = true
          }
        }

        enableStaging = false
      }

      inputs = [
        {
          referenceName = azurerm_data_factory_dataset_azure_sql_table.employee.name
          type          = "DatasetReference"
        }
      ]

      outputs = [
        {
          referenceName = azurerm_data_factory_dataset_delimited_text.employee_csv.name
          type          = "DatasetReference"
        }
      ]
    }
  ])

  depends_on = [
    azurerm_data_factory_dataset_azure_sql_table.employee,
    azurerm_data_factory_dataset_delimited_text.employee_csv
  ]
}
