# =========================

# FIREWALL PUBLIC IP

# =========================

resource "azurerm_public_ip" "firewall" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"
}

# =========================

# AZURE FIREWALL

# =========================

resource "azurerm_firewall" "firewall" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = "AZFW_VNet"
  sku_tier = "Standard"

  # Attach Firewall Policy

  firewall_policy_id = var.firewall_policy_id

  ip_configuration {
    name                 = "firewall-ip-config"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}
