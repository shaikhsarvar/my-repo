resource "azurerm_public_ip" "appgw" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  name                = var.application_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  # =========================
  # APPLICATION GATEWAY SUBNET
  # =========================

  gateway_ip_configuration {
    name      = "appgateway-ip-config"
    subnet_id = var.subnet_id
  }

  # =========================
  # FRONTEND PORT
  # =========================

  frontend_port {
    name = "frontend-port-80"
    port = 80
  }

  # =========================
  # FRONTEND PUBLIC IP
  # =========================

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  #=========================
  #FRONTEND PRIVATE IP used for fire wall
  #=========================

  frontend_ip_configuration {
    name                          = "frontend-ip-private"
    subnet_id                     = var.subnet_id
    private_ip_address            = "10.0.2.10"
    private_ip_address_allocation = "Static"
  }

  # =========================
  # BACKEND POOL
  # VM1 + VM2
  # =========================

  backend_address_pool {
    name = "backend-pool"

    ip_addresses = [
      var.vm1_private_ip,
      var.vm2_private_ip
    ]
  }

  # =========================
  # BACKEND HTTP SETTINGS
  # =========================

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"

    port            = 80
    protocol        = "Http"
    request_timeout = 20

    # Host name override:
    # Pick host name from backend target
    pick_host_name_from_backend_address = true

    probe_name = "http-probe"
  }

  # =========================
  # HEALTH PROBE
  # =========================

  probe {
    name                = "http-probe"
    protocol            = "Http"
    path                = "/"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3

    # Pick host name from backend HTTP settings
    pick_host_name_from_backend_http_settings = true
  }

  # =========================
  # HTTP LISTENER
  # =========================

  #http_listener {
  #  name                           = "http-listener"
  #  frontend_ip_configuration_name = "frontend-ip"
  #  frontend_port_name             = "frontend-port-80"
  #  protocol                       = "Http"
  #}

  #Firewall DNAT → private Application Gateway,
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-private"
    frontend_port_name             = "frontend-port-80"
    protocol                       = "Http"
  }

  # =========================
  # ROUTING RULE
  # =========================

  request_routing_rule {
    name      = "http-routing-rule"
    priority  = 100
    rule_type = "Basic"

    http_listener_name = "http-listener"

    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
  }
}