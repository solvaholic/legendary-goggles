terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=2.71.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Load config for authenticated user
data "azurerm_client_config" "current" {}

# Resource group: push-log
resource "azurerm_resource_group" "push-log" {
  name     = "push-log"
  location = "Central US"
}

# Storage account: pushlogstorage
resource "azurerm_storage_account" "pushlogstorage" {
  name                     = "pushlogstorage"
  account_kind             = "Storage"
  min_tls_version          = "TLS1_2"
  resource_group_name      = azurerm_resource_group.push-log.name
  location                 = azurerm_resource_group.push-log.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Service plan: push-log-svc-plan
resource "azurerm_app_service_plan" "push-log-svc-plan" {
  name                = "push-log-svc-plan"
  location            = azurerm_resource_group.push-log.location
  resource_group_name = azurerm_resource_group.push-log.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

# Function app: solvhaolic-push-log
resource "azurerm_function_app" "solvhaolic-push-log" {
  name                       = "solvhaolic-push-log"
  app_service_plan_id        = azurerm_app_service_plan.push-log-svc-plan.id
  enable_builtin_logging     = false
  identity {
    type = "SystemAssigned"
  }
  location                   = azurerm_resource_group.push-log.location
  resource_group_name        = azurerm_resource_group.push-log.name
  storage_account_access_key = azurerm_storage_account.pushlogstorage.primary_access_key
  storage_account_name       = azurerm_storage_account.pushlogstorage.name
  version                    = "~3"
}

# Key vault: push-log-keyvault
resource "azurerm_key_vault" "push-log-keyvault" {
  name                = "push-log-keyvault"
  location            = azurerm_resource_group.push-log.location
  purge_protection_enabled = false
  resource_group_name = azurerm_resource_group.push-log.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  access_policy { # Permit the application to read secrets
    application_id = ""
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_function_app.solvhaolic-push-log.identity.0.principal_id
    certificate_permissions = []
    key_permissions = []
    secret_permissions = [
      "Get",
      "List",
    ]
    storage_permissions = []
  }
}
