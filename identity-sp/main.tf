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

# App Registration
resource "azuread_application" "pipeline" {
  display_name = var.app_display_name
}

# Service Principal (identité utilisable)
resource "azuread_service_principal" "pipeline" {
  client_id = azuread_application.pipeline.client_id
}

# OIDC trust GitHub Actions -> Entra (Environment dev)
resource "azuread_application_federated_identity_credential" "github_env" {
  application_id = azuread_application.pipeline.id

  display_name = "github-oidc-env-${var.github_env}"
  description  = "OIDC trust for GitHub Actions environment ${var.github_env}"

  audiences = ["api://AzureADTokenExchange"]
  issuer    = "https://token.actions.githubusercontent.com"

  # EXACT subject for GitHub Environment
  subject   = "repo:${var.github_org}/${var.github_repo}:environment:${var.github_env}"
}