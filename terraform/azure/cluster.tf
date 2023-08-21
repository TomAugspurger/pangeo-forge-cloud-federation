resource "azurerm_kubernetes_cluster" "cluster" {
  name                      = var.cluster_name
  location                  = azurerm_resource_group.pangeo_forge.location
  resource_group_name       = azurerm_resource_group.pangeo_forge.name
  dns_prefix                = "${var.group-name}-cluster"
  sku_tier                  = "Standard"
  automatic_channel_upgrade = "stable"

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.pangeo_forge.id
  }

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  # Core node-pool
  default_node_pool {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 1

  }

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_kubernetes_cluster_node_pool" "worker" {
  name                  = "worker"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.cluster.id
  vm_size               = var.vm_size
  enable_auto_scaling   = true
  min_count             = 0
  max_count             = var.max_instances

  zones = []

  # node_labels = {
  #   "kubernetes.azure.com/scalesetpriority" = "spot"
  # }
  # node_taints = [
  #   "kubernetes.azure.com/scalesetpriority=spot:NoSchedule",
  # ]

  lifecycle {
    ignore_changes = [
      node_count,
    ]
  }

}
