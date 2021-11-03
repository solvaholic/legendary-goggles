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
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Configure the Archive Provider
provider "archive" {
}

# Load config for authenticated user
data "azurerm_client_config" "current" {}

# Resource group
resource "azurerm_resource_group" "resource_group" {
  name     = "${var.project}-${var.environment}-resource-group"
  location = var.location
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Storage account
resource "azurerm_storage_account" "storage_account" {
  name                     = "${replace(var.project,"/[^a-z]/","")}${var.environment}storage"
  account_kind             = "Storage"
  min_tls_version          = "TLS1_2"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Application Insights
resource "azurerm_application_insights" "application_insights" {
  name                = "${var.project}-${var.environment}-application-insights"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "Node.JS"
}

# Service plan
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.project}-${var.environment}-app-service-plan"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  kind                = "FunctionApp"
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Function app
resource "azurerm_function_app" "function_app" {
  name                       = "${var.project}-${var.environment}-function-app"
  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id
  app_settings = {
    GITHUB_WEBHOOK_SECRET    = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.key_vault.vault_uri}secrets/github-webhook-secret/)"
    WEBSITE_RUN_FROM_PACKAGE = "1",
  }
  enable_builtin_logging     = false
  identity {
    type = "SystemAssigned"
  }
  location                   = var.location
  resource_group_name        = azurerm_resource_group.resource_group.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  storage_account_name       = azurerm_storage_account.storage_account.name
  version                    = "~3"
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Key vault: key_vault
resource "azurerm_key_vault" "key_vault" {
  name                = "${var.project}-${var.environment}-key-vault"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_key_vault_access_policy" "user_kv_access_policy" {
  # Permit the user to list, set, and destroy secrets
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
  certificate_permissions = []
  key_permissions = []
  secret_permissions = [
    "Delete",
    "Get",
    "List",
    "Purge",
    "Set",
  ]
  storage_permissions = []
}

resource "azurerm_key_vault_access_policy" "app_kv_access_policy" {
  # Permit the application to read secrets
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_function_app.function_app.identity.0.principal_id
  certificate_permissions = []
  key_permissions = []
  secret_permissions = [
    "Get",
    "List",
  ]
  storage_permissions = []
}

data "archive_file" "file_function_app" {
  type        = "zip"
  source_dir  = "../HttpTrigger"
  output_path = "HttpTrigger.zip"
}

locals {
    publish_code_command = "az webapp deployment source config-zip --resource-group ${azurerm_resource_group.resource_group.name} --name ${azurerm_function_app.function_app.name} --src ${data.archive_file.file_function_app.output_path}"
}

resource "null_resource" "function_app_publish" {
  provisioner "local-exec" {
    command = local.publish_code_command
  }
  depends_on = [local.publish_code_command]
  triggers = {
    input_json = filemd5(data.archive_file.file_function_app.output_path)
    publish_code_command = local.publish_code_command
  }
}