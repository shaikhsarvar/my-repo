# =========================
# HUB VIRTUAL NETWORK
# =========================

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = ["10.0.0.0/16"]
}


# =========================
# BACKEND SUBNET
# =========================

resource "azurerm_subnet" "backend" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["10.0.1.0/24"]
}


# =========================
# APPLICATION GATEWAY SUBNET
# =========================

resource "azurerm_subnet" "appgateway" {
  name                 = "appgateway-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["10.0.2.0/24"]
}


# =========================
# VPN GATEWAY SUBNET
# =========================

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["10.0.3.0/27"]
}

# =========================
# AZURE FIREWALL SUBNET
# =========================

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["10.0.4.0/26"]
}

# =========================
# SPOKE VNET
# =========================

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name

  address_space = ["10.1.0.0/16"]
}


# =========================
# SPOKE BACKEND SUBNET
# =========================

resource "azurerm_subnet" "spoke_backend" {
  name                 = "spoke-backend-subnet"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name

  address_prefixes = ["10.1.1.0/24"]
}

# =========================
# AKS SUBNET
# =========================

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name

  address_prefixes = ["10.1.2.0/24"]
}



