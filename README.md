# terraform-appgw-module
Creates:

- Azure App Gateway (Expects an existing VNet but not subnet)
- App Gateway user assigned Managed Identity for access to certificates in Key Vault.
- Key Vault including certificate upload and access policy for managed identity.
- Per site WAF policies assigned to each listener.

Work in progress.
