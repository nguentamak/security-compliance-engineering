terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azuread" {
  # Utilise l'auth Azure CLI (az login)
}

locals {
  groups = {
    "Data Analysts" = {
      mail_nickname = "data-analysts"
      description   = "Groupe Entra pour les Data Analysts"
    }
    "Data Engineers" = {
      mail_nickname = "data-engineers"
      description   = "Groupe Entra pour les Data Engineers"
    }
    "Platform Admins" = {
      mail_nickname = "platform-admins"
      description   = "Admins plateforme data (infra, pipelines, ops)"
    }
    "Security Admins" = {
      mail_nickname = "security-admins"
      description   = "Admins sécurité (policies, accès, audit)"
    }
  }
}

output "group_ids" {
  value = { for k, g in azuread_group.groups : k => g.id }
}

data "azuread_client_config" "current" {}

resource "azuread_group" "groups" {
  for_each         = local.groups
  display_name     = each.key
  mail_nickname    = each.value.mail_nickname
  description      = each.value.description
  security_enabled = true

  # Owner(s) du groupe (ici : moi)
  owners = [data.azuread_client_config.current.object_id]
}

output "current_object_id" {
  value = data.azuread_client_config.current.object_id
}