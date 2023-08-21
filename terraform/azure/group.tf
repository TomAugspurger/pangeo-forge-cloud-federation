resource "azurerm_resource_group" "pangeo_forge" {
    name = var.group-name
    location = var.location
}