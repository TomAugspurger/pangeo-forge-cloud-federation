resource "azurerm_virtual_network" "pangeo_forge" {
  name                = "${var.group-name}-network"
  location            = azurerm_resource_group.pangeo_forge.location
  resource_group_name = azurerm_resource_group.pangeo_forge.name
  address_space       = ["10.0.0.0/8"]
  tags                = {}
}

resource "azurerm_subnet" "node_subnet" {
  name                 = "${var.group-name}-node-subnet"
  virtual_network_name = azurerm_virtual_network.pangeo_forge.name
  resource_group_name  = azurerm_resource_group.pangeo_forge.name
  address_prefixes     = ["10.1.0.0/16"]
}

resource "azurerm_network_security_group" "pangeo_forge" {
  name                = "${var.group-name}-security-group"
  location            = azurerm_resource_group.pangeo_forge.location
  resource_group_name = azurerm_resource_group.pangeo_forge.name
}

resource "azurerm_subnet_network_security_group_association" "pangeo_forge" {
  subnet_id                 = azurerm_subnet.node_subnet.id
  network_security_group_id = azurerm_network_security_group.pangeo_forge.id
}
