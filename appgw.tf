# since these variables are re-used - a locals block makes this more maintainable
locals {
  public_frontend_ip_configuration_name  = "appGwPublicFrontendIp"
  private_frontend_ip_configuration_name = "appGwPrivateFrontendIp"
  app1_name                              = "app1"
  app2_name                              = "app2"
}

# Create application gateway

resource "azurerm_application_gateway" "appgw" {
  name                = "${var.context_short_name}Services-APPGW"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
  firewall_policy_id  = azurerm_web_application_firewall_policy.global.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.appgw.id]
  }

  lifecycle {
        ignore_changes = [
          identity,
        ]
  }

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = "2"
    max_capacity = "10"
  }

  gateway_ip_configuration {
    name      = "hub-gateway-ip-configuration"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = "Http"
    port = 80
  }

  frontend_port {
    name = "Https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.public_frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  frontend_ip_configuration {
    name                          = local.private_frontend_ip_configuration_name
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.gateway_subnet_address_prefix, 4)
    subnet_id                     = azurerm_subnet.appgw.id
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20170401S"
  }

  # Load in the listener certificates

  ssl_certificate {
    name                = "app1cert"
    key_vault_secret_id = ""
  }

  ssl_certificate {
    name                = "app2cert"
    key_vault_secret_id = ""
  }

  # Load in the root certificates for end-to-end SSL if needed.

  trusted_root_certificate {
    name = "rootcert1"
    data = ""
  }

  trusted_root_certificate {
    name = "rootcert2"
    data = ""
  }

  # Use the sections below as templates to create configs for new applications.

  # Create app1 config

  backend_address_pool {
    name = "${local.app1_name}-backend"
    ip_addresses = ["10.220.19.18"]
  }

  backend_http_settings {
    name                  = "${local.app1_name}-https"
    cookie_based_affinity = "Enabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 900
    host_name             = "app1.org"
    probe_name            = "${local.app1_name}-probe"
  }

  probe {
    name = "${local.app1_name}-probe"
    host = "app1.org"
    interval = 30
    protocol = "Https"
    path = "/Account/Login.htm"
    timeout = 30
    unhealthy_threshold = 3
  }

  http_listener {
    name                           = "${local.app1_name}-https-listener"
    frontend_ip_configuration_name = local.private_frontend_ip_configuration_name
    frontend_port_name             = "Https"
    protocol                       = "Https"
    host_name                      = "app1.org"
    ssl_certificate_name           = "app1cert"
    require_sni                    = "true"
    firewall_policy_id             = azurerm_web_application_firewall_policy.app1.id
  }

  http_listener {
    name                           = "${local.app1_name}-http-listener"
    frontend_ip_configuration_name = local.private_frontend_ip_configuration_name
    frontend_port_name             = "Http"
    protocol                       = "Http"
    host_name                      = "app1.org"
    firewall_policy_id             = azurerm_web_application_firewall_policy.app1.id
  }

  request_routing_rule {
    name                       = "${local.app1_name}-https-rule"
    rule_type                  = "Basic"
    http_listener_name         = "${local.app1_name}-https-listener"
    backend_address_pool_name  = "${local.app1_name}-backend"
    backend_http_settings_name = "${local.app1_name}-https"
  }

  request_routing_rule {
    name                        = "${local.app1_name}-http-rule"
    rule_type                   = "Basic"
    http_listener_name          = "${local.app1_name}-http-listener"
    redirect_configuration_name = "${local.app1_name}-redirect"
  }

  redirect_configuration {
    name                  = "${local.app1_name}-redirect"
    redirect_type         = "Permanent"
    target_listener_name  = "${local.app1_name}-https-listener"
    include_path          = "true"
    include_query_string  = "true"
  }

  # Create a config for a static website hosted in a storage account

  backend_address_pool {
    name = "${local.app2_name}-backend"
    fqdns = ["app2.z6.web.core.windows.net"]
  }

  backend_http_settings {
    name                  = "${local.app2_name}-https"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 60
    host_name             = "app2.z6.web.core.windows.net"
  }

  http_listener {
    name                           = "${local.app2_name}-https-listener"
    frontend_ip_configuration_name = local.private_frontend_ip_configuration_name
    frontend_port_name             = "Https"
    protocol                       = "Https"
    host_names                     = ["www.app2.org", "app2.org"]
    ssl_certificate_name           = "app2cert"
    require_sni                    = "true"
    firewall_policy_id             = azurerm_web_application_firewall_policy.app2.id
  }

  http_listener {
    name                           = "${local.app2_name}-http-listener"
    frontend_ip_configuration_name = local.private_frontend_ip_configuration_name
    frontend_port_name             = "Http"
    protocol                       = "Http"
    host_names                     = ["www.app2.org", "app2.org"]
    firewall_policy_id             = azurerm_web_application_firewall_policy.app2.id
  }

  request_routing_rule {
    name                       = "${local.app2_name}-https-rule"
    rule_type                  = "Basic"
    http_listener_name         = "${local.app2_name}-https-listener"
    backend_address_pool_name  = "${local.app2_name}-backend"
    backend_http_settings_name = "${local.app2_name}-https"
  }

  request_routing_rule {
    name                        = "${local.app2_name}-http-rule"
    rule_type                   = "Basic"
    http_listener_name          = "${local.app2_name}-http-listener"
    redirect_configuration_name = "${local.app2_name}-redirect"
  }

  redirect_configuration {
    name                  = "${local.app2_name}-redirect"
    redirect_type         = "Permanent"
    target_url            = "https://www.app2.org"
    include_path          = "false"
    include_query_string  = "false"
  }

}


