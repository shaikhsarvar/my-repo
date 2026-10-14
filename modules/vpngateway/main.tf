# =========================
# VPN PUBLIC IP
# =========================

resource "azurerm_public_ip" "vpn" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"
  zones             = ["1", "2", "3"]
}


# =========================
# AZURE VPN GATEWAY
# =========================

resource "azurerm_virtual_network_gateway" "vpn" {
  name                = var.vpn_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "VpnGw1AZ"

  active_active = false
  bgp_enabled   = false

  ip_configuration {
    name                          = "vpn-gateway-ip-config"
    public_ip_address_id          = azurerm_public_ip.vpn.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }
}


# =========================
# ON-PREMISES NETWORK GATEWAY
# =========================

resource "azurerm_local_network_gateway" "onprem" {
  name                = "lng-onprem"
  location            = var.location
  resource_group_name = var.resource_group_name

  gateway_address = "203.0.113.10"

  address_space = [
    "172.10.0.0/16"
  ]
}


# =========================
# SITE-TO-SITE VPN CONNECTION
# =========================

resource "azurerm_virtual_network_gateway_connection" "onprem" {
  name                = "vpn-connection-onprem"
  location            = var.location
  resource_group_name = var.resource_group_name

  type = "IPsec"

  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem.id

  shared_key = var.vpn_shared_key
}