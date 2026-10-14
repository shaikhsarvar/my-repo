
variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sql_server_name" {
  type = string
}

variable "sql_database_name" {
  type    = string
  default = "sqldb-demo"
}

variable "sql_admin_username" {
  type    = string
  default = "sqladminuser"
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}

variable "storage_account_name" {
  type = string
}

variable "data_factory_name" {
  type = string
}

variable "adls_filesystem_name" {
  type    = string
  default = "raw"
}

variable "sql_schema_name" {
  type    = string
  default = "dbo"
}

variable "sql_table_name" {
  type    = string
  default = "Employee"
}

variable "adls_output_file" {
  type    = string
  default = "Employee.csv"
}
