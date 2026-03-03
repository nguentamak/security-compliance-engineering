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

data "azuread_client_config" "current" {}

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

resource "azuread_group" "groups" {
  for_each         = local.groups
  display_name     = each.key
  mail_nickname    = each.value.mail_nickname
  description      = each.value.description
  security_enabled = true

  # Owners du groupe (recommandé : au moins 1-2 owners)
  owners = [data.azuread_client_config.current.object_id]
}