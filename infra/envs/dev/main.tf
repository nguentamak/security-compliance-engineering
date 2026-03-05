data "azurerm_client_config" "current" {}

############################
# 0) INPUTS
############################
variable "principal_object_ids" {
  description = "Object IDs (Entra) des groupes/identités utilisés pour le RBAC"
  type = object({
    grp_data_analysts     = string
    grp_data_engineers    = string
    grp_platform_admins   = string
    grp_security_admins   = string
    mi_adf_runtime        = string # objectId MI ADF (ou SP)
    mi_databricks_runtime = string # objectId MI Databricks (ou SP)
    sp_cicd_deployer      = string # objectId SP CI/CD (ou MI)
  })
}

############################
# 1) RESSOURCES “stack data”
############################
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  suffix = random_string.suffix.result
}


resource "azurerm_resource_group" "rg" {
  name     = "rg-data-dev"
  location = "westeurope"
}

resource "azurerm_storage_account" "st" {
  # ⚠️ Doit être UNIQUE globalement + lowercase/chiffres uniquement (3-24 chars)
  name                     = "stdatadev12345"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
}

resource "azurerm_key_vault" "kv" {
  name                          = "kv-data-dev-${local.suffix}"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  public_network_access_enabled = false
}

# ADF (minimal)
#resource "azurerm_data_factory" "adf" {
#  name                = "adf-data-dev-${local.suffix}"
#  location            = azurerm_resource_group.rg.location # typo corrigée
#  resource_group_name = azurerm_resource_group.rg.name
#  identity {
#    type = "SystemAssigned"
#  }
#}

# Databricks (minimal workspace)
resource "azurerm_databricks_workspace" "dbw" {
  name                = "dbw-data-dev-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "standard"
}

#####################################
# 2) MAP RBAC pour DEV (plus permissif)
#####################################
locals {
  role_map = {
    # --- HUMANS ---
    dev_analysts_rg_reader = {
      scope                = azurerm_resource_group.rg.id
      role_definition_name = "Reader"
      principal_id         = var.principal_object_ids.grp_data_analysts
    }
    dev_analysts_storage_reader = {
      scope                = azurerm_storage_account.st.id
      role_definition_name = "Storage Blob Data Reader"
      principal_id         = var.principal_object_ids.grp_data_analysts
    }

    dev_engineers_rg_contributor = {
      scope                = azurerm_resource_group.rg.id
      role_definition_name = "Contributor"
      principal_id         = var.principal_object_ids.grp_data_engineers
    }

    dev_platform_rg_contributor = {
      scope                = azurerm_resource_group.rg.id
      role_definition_name = "Contributor"
      principal_id         = var.principal_object_ids.grp_platform_admins
    }

    dev_security_rg_uua = {
      scope                = azurerm_resource_group.rg.id
      role_definition_name = "User Access Administrator"
      principal_id         = var.principal_object_ids.grp_security_admins
    }

    # --- RUNTIMES ---
    dev_adf_storage_contrib = {
      scope                = azurerm_storage_account.st.id
      role_definition_name = "Storage Blob Data Contributor"
      principal_id         = var.principal_object_ids.mi_adf_runtime
    }
    #dev_adf_kv_secrets_user = {
    #  scope                = azurerm_key_vault.kv.id
    #  role_definition_name = "Key Vault Secrets User"
    #  principal_id         = var.principal_object_ids.mi_adf_runtime
    #}

    dev_dbx_storage_contrib = {
      scope                = azurerm_storage_account.st.id
      role_definition_name = "Storage Blob Data Contributor"
      principal_id         = var.principal_object_ids.mi_databricks_runtime
    }
    dev_dbx_kv_secrets_user = {
      scope                = azurerm_key_vault.kv.id
      role_definition_name = "Key Vault Secrets User"
      principal_id         = var.principal_object_ids.mi_databricks_runtime
    }

    # --- CI/CD Deploy identity ---
    dev_cicd_rg_contributor = {
      scope                = azurerm_resource_group.rg.id
      role_definition_name = "Contributor"
      principal_id         = var.principal_object_ids.sp_cicd_deployer
    }
  }
}

module "rbac" {
  source      = "../../modules/rbac"
  assignments = local.role_map
}