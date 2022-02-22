locals {
  naming_prefix = "${var.env}-${var.stage}"
  location      = data.azurerm_resource_group.rg.location
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

resource "random_string" "random_suffix" {
  length  = 4
  special = false
}

resource "azurerm_key_vault" "vault" {
  # Vault names are globaly unique and max 24 chars, so add random string
  name                       = "${local.naming_prefix}-KV-${random_string.random_suffix.result}"
  location                   = local.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 90
  purge_protection_enabled   = false
  sku_name                   = "standard"

  # Allow access for Builder ID
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = ["create", "get", "list", "recover", "delete", "purge"] # delete and purge for "terraform destroy" to work
    secret_permissions      = ["set", "get", "delete", "purge", "recover", "list"]
  }

  # Allow access from the gateway to access the certificate
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.agw.principal_id

    certificate_permissions = ["get"]
    secret_permissions      = ["get"]
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
  tags = var.standard_tags
}

# Create a self signed certificate
resource "azurerm_key_vault_certificate" "certificate" {
  name         = "${local.naming_prefix}-cert"
  key_vault_id = azurerm_key_vault.vault.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = ["${var.webserver_name}.azurewebsites.net"]
      }

      subject            = "CN=${var.webserver_name}.azurewebsites.net"
      validity_in_months = 12
    }
  }
}

resource "azurerm_user_assigned_identity" "agw" {
  location            = local.location
  resource_group_name = var.resource_group_name
  name                = "agw-msi"
}

# TODO Can this be removed
# Allows some time for the certificate to be created
resource "time_sleep" "wait_seconds" {
  depends_on = [azurerm_key_vault_certificate.certificate]

  create_duration = "15s"
}

