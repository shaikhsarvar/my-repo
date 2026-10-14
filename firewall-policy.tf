#create the Firewall Policy

resource "azurerm_firewall_policy" "policy" {
  name                = "azfw-policy"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku = "Standard"
}
# =========================
# FIREWALL NETWORK RULE
# VM → FIREWALL → INTERNET
# =========================

resource "azurerm_firewall_policy_rule_collection_group" "network" {
  name               = "network-rules"
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = 100

  network_rule_collection {
    name     = "allow-internet"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "allow-https"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.1.0/24"]
      destination_addresses = ["*"]
      destination_ports     = ["443"]
    }

    rule {
      name                  = "allow-http"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.1.0/24"]
      destination_addresses = ["*"]
      destination_ports     = ["80"]
    }
  }
}
#DNAT rule firewall to application gatway

resource "azurerm_firewall_policy_rule_collection_group" "appgateway" {
  name               = "appgateway-rules"
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = 200

  nat_rule_collection {
    name     = "dnat-appgateway"
    priority = 200
    action   = "Dnat"

    rule {
      name                = "http-to-appgateway"
      protocols           = ["TCP"]
      source_addresses    = ["*"]
      destination_address = module.firewall.firewall_public_ip
      destination_ports   = ["80"]

      translated_address = module.applicationgateway.private_ip_address
      translated_port    = "80"
    }
  }
}


# =========================================================
# AKS OUTBOUND - ALLOW INTERNET ANY
# =========================================================

resource "azurerm_firewall_policy_rule_collection_group" "aks_outbound" {

  name               = "aks-outbound-rules"
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = 400

  network_rule_collection {

    name     = "aks-internet"
    priority = 400
    action   = "Allow"

    rule {

      name = "allow-aks-internet-any"

      protocols = [
        "Any"
      ]

      # AKS SUBNET
      source_addresses = [
        "10.1.2.0/24"
      ]

      destination_addresses = [
        "*"
      ]

      destination_ports = [
        "*"
      ]
    }
  }
}

# =========================================================
# DNAT RULE - FIREWALL TO AKS INTERNAL LOAD BALANCER  
# =========================================================\

# Requre permission on aks subnet to get traffic aceess from firewall 

resource "azurerm_firewall_policy_rule_collection_group" "aks" {
  name               = "aks-rules"
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = 300

  nat_rule_collection {
    name     = "dnat-aks"
    priority = 300
    action   = "Dnat"

    rule {
      name                = "http-to-aks"
      protocols           = ["TCP"]
      source_addresses    = ["*"]
      destination_address = module.firewall.firewall_public_ip
      destination_ports   = ["8080"]

      translated_address = "10.1.2.50"
      translated_port    = "80"
    }
  }
}