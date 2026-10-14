# =========================
#  HUB RESOURCE GROUP
# =========================

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# =========================
#  spoke RESOURCE GROUP
# =========================

resource "azurerm_resource_group" "spoke" {
  name     = "rg-spoke"
  location = var.location
}


