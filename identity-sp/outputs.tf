output "azure_client_id" {
  value = azuread_application.pipeline.client_id
}

output "azure_principal_object_id" {
  value = azuread_service_principal.pipeline.object_id
}