
# =========================
# Application gatway
# =========================
module "applicationgateway" {
  source = "./modules/applicationgateway"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.appgateway.id

  application_gateway_name = "appgw-prod"
  public_ip_name           = "pip-appgw-prod"

  #attached to backend hub vm
  #vm1_private_ip = module.vm1.private_ip
  #vm2_private_ip = module.vm2.private_ip

  # =========================
  # SPOKE VM BACKEND
  # =========================

  vm1_private_ip = module.spoke_vm1.private_ip
  vm2_private_ip = module.spoke_vm2.private_ip
}

# =========================
# SITE-TO-SITE VPN GATEWAY
# =========================

#module "vpngateway" {
# source = "./modules/vpngateway"

# resource_group_name = azurerm_resource_group.rg.name
#location            = azurerm_resource_group.rg.location

#gateway_subnet_id = azurerm_subnet.gateway.id

#public_ip_name   = "pip-vpn-gateway"
#vpn_gateway_name = "vpn-gateway-prod"

# vpn_shared_key = var.vpn_shared_key
#}

# =========================

# AZURE FIREWALL

# =========================

module "firewall" {
  source = "./modules/firewall"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  firewall_name      = "azfw-prod"
  public_ip_name     = "pip-azfw-prod"
  firewall_subnet_id = azurerm_subnet.firewall.id

  firewall_policy_id = azurerm_firewall_policy.policy.id
}

# =========================
# SPOKE VM 01
# =========================

module "spoke_vm1" {
  source = "./modules/vm"

  resource_group_name = azurerm_resource_group.spoke.name
  location            = azurerm_resource_group.spoke.location

  subnet_id = azurerm_subnet.spoke_backend.id

  vm_name        = "spoke-vm-01"
  admin_username = var.admin_username
  admin_password = var.admin_password
}


# =========================
# SPOKE VM 02
# =========================

module "spoke_vm2" {
  source = "./modules/vm"

  resource_group_name = azurerm_resource_group.spoke.name
  location            = azurerm_resource_group.spoke.location

  subnet_id = azurerm_subnet.spoke_backend.id

  vm_name        = "spoke-vm-02"
  admin_username = var.admin_username
  admin_password = var.admin_password
}

# =========================
# AKS DEV
# =========================

module "aks_dev" {
  source = "./modules/aks"

  aks_name   = "aks-dev"
  dns_prefix = "aks-dev"

  resource_group_name = azurerm_resource_group.spoke.name
  location            = azurerm_resource_group.spoke.location

  aks_subnet_id = azurerm_subnet.aks.id

  kubernetes_version = var.kubernetes_version

  system_vm_size    = var.system_vm_size
  system_node_count = var.system_node_count

  user_vm_size    = var.user_vm_size
  user_node_count = var.user_node_count

  #depends_on = [
  #azurerm_subnet_route_table_association.aks
  #]
}


module "data_platform" {
  source = "./modules/SQL-ADF-Datalake"

  resource_group_name  = azurerm_resource_group.spoke.name
  location             = azurerm_resource_group.spoke.location
  sql_server_name      = var.sql_server_name
  sql_database_name    = var.sql_database_name
  sql_admin_username   = var.sql_admin_username
  sql_admin_password   = var.sql_admin_password
  storage_account_name = var.storage_account_name
  data_factory_name    = var.data_factory_name
  adls_filesystem_name = var.adls_filesystem_name

  sql_schema_name  = "dbo"
  sql_table_name   = "Employee"
  adls_output_file = "Employee.csv"
}
