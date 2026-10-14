# =========================
# AKS CLUSTER
# =========================

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  identity {
    type = "SystemAssigned"
  }

  # =========================
  # NODE PROVISIONING
  # =========================

  node_provisioning_profile {
    mode = "Auto"
  }

  # =========================
  # SYSTEM NODE POOL
  # =========================

  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_vm_size
    node_count                   = var.system_node_count
    vnet_subnet_id               = var.aks_subnet_id
    os_disk_size_gb              = 128
    only_critical_addons_enabled = true

    node_labels = {
      nodepool = "system"
      workload = "system"
    }
  }

  # =========================
  # NETWORK vail LB
  # =========================

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"

    # userd force route table for firewall route table desable in root aks-udr.tf
    # if route table enable to forece to firewall than we need to enable it 

    #outbound_type = "userDefinedRouting"

    #service_cidr   = "10.2.0.0/16"
    #dns_service_ip = "10.2.0.10"
  }

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}


# =========================
# USER NODE POOL
# =========================

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id

  vm_size         = var.user_vm_size
  node_count      = var.user_node_count
  vnet_subnet_id  = var.aks_subnet_id
  mode            = "User"
  os_disk_size_gb = 128

  # =========================
  # APPLICATION WORKLOAD LABELS
  # =========================

  node_labels = {
    nodepool = "user"
    workload = "application"
  }

  tags = {
    Environment = "Dev"
    NodeType    = "User"
    Workload    = "Application"
  }
}

# =========================
# APPLICATION LOAD BALANCER SERVICE TO ACCESS APPLICATION ON PUBLIC IP
# =========================

resource "kubernetes_service_v1" "my_app_lb" {
  metadata {
    name      = "my-app-lb"
    namespace = "default"
  }

  spec {
    selector = {
      app = "my-app"
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}