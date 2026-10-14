# =========================
# HUB → SPOKE
# =========================

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name = "hub-to-spoke"

  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  remote_virtual_network_id = azurerm_virtual_network.spoke.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}


# =========================
# SPOKE → HUB
# =========================

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name = "spoke-to-hub"

  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name

  remote_virtual_network_id = azurerm_virtual_network.vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}