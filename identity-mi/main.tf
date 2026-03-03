terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "identity_name" { type = string }

resource "azurerm_resource_group" "id" {
  name     = var.resource_group_name
  location = var.location
}

# ✅ User Assigned Managed Identity (réutilisable)
resource "azurerm_user_assigned_identity" "pipeline" {
  name                = var.identity_name
  location            = azurerm_resource_group.id.location
  resource_group_name = azurerm_resource_group.id.name
}