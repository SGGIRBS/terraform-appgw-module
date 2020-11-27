# terraform-appgw-module
Creates:

- Azure Application Gateway (Expects an existing VNet but not a subnet)
- Key Vault (Includes certificate upload).
- Managed Identity for App GW to Key Vault access.
- Per site WAF polcies assigned to each listener.

Work in progress.
