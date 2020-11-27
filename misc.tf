# Create resource group

resource "azurerm_resource_group" "rg" {
  name     = "${var.context_short_name}-APPGW-${var.environment_short_name}-RG"
  location = var.location
  tags     = var.tags
}

# Create public ip address

resource "azurerm_public_ip" "appgw" {
  name                = "${var.context_short_name}APPGW-PIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Create gateway subnet

resource "azurerm_subnet" "appgw" {
  name                 = "ApplicationGatewaySubnet"
  resource_group_name  = var.virtual_network_resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefix       = var.gateway_subnet_address_prefix
  service_endpoints    = [
    "Microsoft.Storage",
    "Microsoft.Web",
  ]
}