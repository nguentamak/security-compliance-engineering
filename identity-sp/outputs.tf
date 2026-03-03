output "pipeline_principal_object_id" {
  # Pour tes azurerm_role_assignment, tu veux l'OBJECT ID du service principal
  value = azuread_service_principal.pipeline.object_id
}

output "pipeline_client_id" {
  value = azuread_application.pipeline.client_id
}

output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}

data "azuread_client_config" "current" {}