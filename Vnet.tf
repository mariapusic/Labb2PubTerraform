resource "azurerm_virtual_network" "MariaVnet" {
  name                = "Mariavnet"
  location            = local.RGlocation
  resource_group_name = local.RGname
  address_space       = ["10.0.0.0/16"]

  depends_on = [azurerm_resource_group.MariaRG]

}

resource "azurerm_subnet" "BESubnet" {
  name                 = "besubnet"
  resource_group_name  = local.RGname
  virtual_network_name = azurerm_virtual_network.MariaVnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Web"]
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }

  }

  depends_on = [azurerm_virtual_network.MariaVnet]

}


resource "azurerm_app_service_virtual_network_swift_connection" "BESUBNETCONNECTION" {
  app_service_id = azurerm_linux_web_app.WebApp.id
  subnet_id      = azurerm_subnet.BESubnet.id
  depends_on     = [azurerm_subnet.BESubnet, azurerm_linux_web_app.WebApp]
}


//Network Security Group access rules
resource "azurerm_network_security_group" "BENSG" {
  name                = "bensg"
  location            = local.RGlocation
  resource_group_name = local.RGname
}
