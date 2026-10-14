resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# =========================
# NETWORK SECURITY GROUP
# =========================

resource "azurerm_network_security_group" "backend" {
  name                = "${var.vm_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name      = "Allow-HTTP-80"
    priority  = 100
    direction = "Inbound"
    access    = "Allow"
    protocol  = "Tcp"

    source_port_range      = "*"
    destination_port_range = "80"

    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# =========================
# ATTACH NSG TO NIC
# =========================

resource "azurerm_network_interface_security_group_association" "backend" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.backend.id
}

# =========================
# LINUX VIRTUAL MACHINE
# =========================

resource "azurerm_linux_virtual_machine" "vm" {

  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location

  size = "Standard_B2s"

  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  # =========================================================
  # INSTALL NGINX + CUSTOM HTML PAGE
  # =========================================================

  custom_data = base64encode(
    templatefile("${path.module}/nginx.html", {
      vm_name = var.vm_name
    })
  )

  # =========================
  # OS DISK
  # =========================

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # =========================
  # UBUNTU IMAGE
  # =========================

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}