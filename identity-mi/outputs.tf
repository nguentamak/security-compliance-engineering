output "pipeline_principal_object_id" {
  # IMPORTANT: pour RBAC Azure, c'est le principal_id qu'il faut
  value = azurerm_user_assigned_identity.pipeline.principal_id
}

output "pipeline_client_id" {
  value = azurerm_user_assigned_identity.pipeline.client_id
}

output "pipeline_identity_resource_id" {
  value = azurerm_user_assigned_identity.pipeline.id
}