output "resource_group_name" {
  value = azurerm_resource_group.resource_group.name
  description = "Deployed resource group name"
}

output "function_app_name" {
  value = azurerm_function_app.function_app.name
  description = "Deployed function app name"
}

output "function_app_default_hostname" {
  value = azurerm_function_app.function_app.default_hostname
  description = "Deployed function app hostname"
}
