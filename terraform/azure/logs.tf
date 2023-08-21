resource "azurerm_log_analytics_workspace" "pangeo_forge" {
  name                = "${var.group-name}-logs"
  location            = azurerm_resource_group.pangeo_forge.location
  resource_group_name = azurerm_resource_group.pangeo_forge.name
  sku                 = "PerGB2018"
  tags                = {}
}

resource "azurerm_log_analytics_solution" "pangeo_forge" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.pangeo_forge.location
  resource_group_name   = azurerm_resource_group.pangeo_forge.name
  workspace_resource_id = azurerm_log_analytics_workspace.pangeo_forge.id
  workspace_name        = azurerm_log_analytics_workspace.pangeo_forge.name

  tags = {}

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_application_insights" "pangeo_forge" {
  name                = "${var.group-name}-appinsights"
  location            = azurerm_resource_group.pangeo_forge.location
  resource_group_name = azurerm_resource_group.pangeo_forge.name
  workspace_id        = azurerm_log_analytics_workspace.pangeo_forge.id
  application_type    = "other"
  tags                = {}
}
