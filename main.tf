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

# Storage account: storageaccountpushl9725
resource "azurerm_storage_account" "storageaccountpushl9725" {
  name                     = "storageaccountpushl9725"
  account_kind             = "Storage"
  min_tls_version          = "TLS1_2"
  resource_group_name      = azurerm_resource_group.push-log.name
  location                 = azurerm_resource_group.push-log.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Service plan: ASP-pushlog-94c0
resource "azurerm_app_service_plan" "ASP-pushlog-94c0" {
  name                = "ASP-pushlog-94c0"
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
  app_service_plan_id        = azurerm_app_service_plan.ASP-pushlog-94c0.id
  enable_builtin_logging     = false
  location                   = azurerm_resource_group.push-log.location
  resource_group_name        = azurerm_resource_group.push-log.name
  storage_account_access_key = azurerm_storage_account.storageaccountpushl9725.primary_access_key
  storage_account_name       = azurerm_storage_account.storageaccountpushl9725.name
  version                    = "~3"
}

# Key vault: push-log-keyvault
resource "azurerm_key_vault" "push-log-keyvault" {
  name                = "push-log-keyvault"
  enable_rbac_authorization = false
  enabled_for_deployment = false
  enabled_for_disk_encryption = false
  enabled_for_template_deployment = false
  location            = "eastus"
  purge_protection_enabled = false
  resource_group_name = azurerm_resource_group.push-log.name
  sku_name            = "standard"
  tags                = {}
  tenant_id           = data.azurerm_client_config.current.tenant_id
  access_policy = [
    { # Permit the application to read secrets
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
    },
    { # Permit the authenticated user to admin
      application_id = ""
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = data.azurerm_client_config.current.object_id
      "certificate_permissions": [
        "Get",
        "List",
        "Delete",
        "Create",
        "Import",
        "Update",
        "ManageContacts",
        "GetIssuers",
        "ListIssuers",
        "SetIssuers",
        "DeleteIssuers",
        "ManageIssuers",
        "Recover"
      ],
      "key_permissions": [
        "Get",
        "Create",
        "Delete",
        "List",
        "Update",
        "Import",
        "Backup",
        "Restore",
        "Recover"
      ],
      "secret_permissions": [
        "Get",
        "List",
        "Set",
        "Delete",
        "Backup",
        "Restore",
        "Recover"
      ],
      "storage_permissions": [
        "Get",
        "List",
        "Delete",
        "Set",
        "Update",
        "RegenerateKey",
        "SetSAS",
        "ListSAS",
        "GetSAS",
        "DeleteSAS"
      ],
    }
  ]
}
