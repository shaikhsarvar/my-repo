# Hub Resource Group
variable "resource_group_name" {
  type    = string
  default = "Hub-RG"
}

# Spoke Resource Group
variable "spoke_resource_group_name" {
  type    = string
  default = "rg-spoke"
}

variable "location" {
  type    = string
  default = "Central India"
}

variable "vnet_name" {
  type    = string
  default = "vnet-hub"
}

variable "subnet_name" {
  type    = string
  default = "backend-subnet"
}


variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "vpn_shared_key" {
  type      = string
  sensitive = true
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version"
  type        = string
  default     = "1.35"
}

variable "system_vm_size" {
  description = "AKS system node VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "system_node_count" {
  description = "AKS system node count"
  type        = number
  default     = 1
}

variable "user_vm_size" {
  description = "AKS user node VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "user_node_count" {
  description = "AKS user node count"
  type        = number
  default     = 1
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

variable "adls_filesystem_name" {
  type    = string
  default = "raw"
}
variable "data_factory_name" {
  type = string
}

