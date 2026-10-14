# =========================
# AKS ROUTE TABLE
# =========================

#resource "azurerm_route_table" "aks" {
# name                = "rt-aks-firewall"
#location            = azurerm_resource_group.spoke.location
#resource_group_name = azurerm_resource_group.spoke.name

#route {
# name                   = "default-to-firewall"
#address_prefix         = "0.0.0.0/0"
#next_hop_type          = "VirtualAppliance"
#next_hop_in_ip_address = module.firewall.firewall_private_ip
#}
#}

# =========================
# AKS UDR ASSOCIATION
# =========================

#resource "azurerm_subnet_route_table_association" "aks" {
# subnet_id      = azurerm_subnet.aks.id
#route_table_id = azurerm_route_table.aks.id
#}