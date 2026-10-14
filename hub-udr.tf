# =========================

# ROUTE TABLE FOR BACKEND

# =========================

#resource "azurerm_route_table" "backend" {
# name                = "rt-backend"
#location            = azurerm_resource_group.rg.location
#resource_group_name = azurerm_resource_group.rg.name

#route {
# name                   = "default-to-firewall"
#address_prefix         = "0.0.0.0/0"
#next_hop_type          = "VirtualAppliance"
#next_hop_in_ip_address = module.firewall.firewall_private_ip
#}
#}

# =========================

# ASSOCIATE ROUTE TABLE

# WITH BACKEND vm SUBNET

# =========================

#resource "azurerm_subnet_route_table_association" "backend" {
# subnet_id      = azurerm_subnet.backend.id
#route_table_id = azurerm_route_table.backend.id
#}
