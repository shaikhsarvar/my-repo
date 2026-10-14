# =========================
# SPOKE ROUTE TABLE
# ALL TRAFFIC → HUB FIREWALL
# =========================

#resource "azurerm_route_table" "spoke" {
# name                = "rt-spoke-firewall"
#location            = azurerm_resource_group.spoke.location
#resource_group_name = azurerm_resource_group.spoke.name

#route {
# name                   = "all-traffic-to-firewall"
#address_prefix         = "0.0.0.0/0"
#next_hop_type          = "VirtualAppliance"
#next_hop_in_ip_address = module.firewall.firewall_private_ip
#}
#}


# =========================
# ATTACH UDR TO SPOKE SUBNET
# =========================

#resource "azurerm_subnet_route_table_association" "spoke_backend" {
# subnet_id      = azurerm_subnet.spoke_backend.id
#route_table_id = azurerm_route_table.spoke.id
#}