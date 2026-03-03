terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}

provider "azuread" {}

# 1) Application Entra (App Registration)
resource "azuread_application" "pipeline" {
  display_name = var.app_display_name
}

# 2) Service Principal lié à l'app (l'identité utilisable pour RBAC)
resource "azuread_service_principal" "pipeline" {
  client_id = azuread_application.pipeline.client_id
}

# 3) Federated Credential pour OIDC GitHub -> Entra SP
resource "azuread_application_federated_identity_credential" "github" {
  application_id = azuread_application.pipeline.id
  display_name   = "github-oidc"
  description    = "OIDC trust for GitHub Actions"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"

  # Exemple “environment”. Alternatives: repo:ref:refs/heads/main, etc.
  subject        = "repo:${var.github_org}/${var.github_repo}:environment:${var.github_env}"
}