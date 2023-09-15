resource "azurerm_service_plan" "MariaSP" {
  name                = "MariaSP"
  resource_group_name = local.RGname
  location            = local.RGlocation
  os_type             = "Linux"
  sku_name            = "B1"
  depends_on          = [azurerm_resource_group.MariaRG]
}

resource "azurerm_linux_web_app" "WebApp" {
  name                = "webappMariaiths"
  resource_group_name = local.RGname
  location            = local.RGlocation
  service_plan_id     = azurerm_service_plan.MariaSP.id

  site_config {
    application_stack {
      dotnet_version = "7.0"

    }
  }


  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"       = "1"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "1"
    "DatabaseName"               = azurerm_cosmosdb_sql_database.CosmosDb.name
    "ContainerName"              = azurerm_cosmosdb_sql_container.MariaContainer.name
  }

  connection_string {
    name  = "CosmosDB"
    type  = "Custom"
    value = azurerm_cosmosdb_account.cosmosdb_account.connection_strings[0]
  }

  depends_on = [azurerm_service_plan.MariaSP]
}