
# Create managed identity for accessing key vault

resource "azurerm_user_assigned_identity" "appgw" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  name = "appgwKeyVaultIdentity"
}

data "azurerm_user_assigned_identity" "appgw" {
  name                = azurerm_user_assigned_identity.appgw.name
  resource_group_name = azurerm_resource_group.rg.name
}


# Create Key Vault

resource "azurerm_key_vault" "certificates" {
  name                     = "${var.context_short_name}-${var.service_short_name}-${var.environment_short_name}-KV"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  tenant_id                = var.tenant-id
  soft_delete_enabled      = true
  purge_protection_enabled = false
  sku_name                 = "standard"
  enabled_for_template_deployment = true
  tags                     = var.tags
}

resource "azurerm_key_vault_access_policy" "appgw" {
  key_vault_id = azurerm_key_vault.certificates.id

  tenant_id = var.tenant-id
  object_id = data.azurerm_user_assigned_identity.appgw.principal_id

  secret_permissions = [
    "get", "list",
  ]

  certificate_permissions = [
    "get", "list",
  ]

}

# Upload the PFX certificate. This example assumes the PFX file is located in the same directory at certificate-to-import.pfx

resource "azurerm_key_vault_certificate" "example" {
  name         = "imported-cert"
  key_vault_id = azurerm_key_vault.example.id

  certificate {
    contents = filebase64("certificate-to-import.pfx")
    password = "var.certificate_1_password"
  }

  certificate_policy {
    issuer_parameters {
      name = "Unknown"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
    }

    secret_properties {
      content_type = "application/x-pkcs12" // use application/x-pem-file for pem
    }
  }
}