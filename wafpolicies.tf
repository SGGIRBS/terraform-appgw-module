# Example WAF policy configs for per site assignment to the application gateway

resource "azurerm_web_application_firewall_policy" "global" {
  name                = "global-wafpolicy"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {

    managed_rule_set {
      type                        = "OWASP"
      version                     = "3.1"
    }
  }

}

resource "azurerm_web_application_firewall_policy" "app1" {
  name                = "app1-wafpolicy"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = false
  }

  managed_rules {

    managed_rule_set {
      type    = "OWASP"
      version = "3.1"
      rule_group_override {
        rule_group_name = "REQUEST-932-APPLICATION-ATTACK-RCE"
        disabled_rules = [
            "932150"
        ]
      }

      rule_group_override {
        rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
        disabled_rules = [
            "920230",
            "920290",
        ]
      }
    }
  }

}

resource "azurerm_web_application_firewall_policy" "app2" {
  name                = "app2-wafpolicy"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  policy_settings {
    enabled                     = true
    mode                        = "Detection"
    request_body_check          = true
    file_upload_limit_in_mb     = 1
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    exclusion {
      match_variable          = "RequestArgNames"
      selector                = "utmr"
      selector_match_operator = "Contains"
    }

    managed_rule_set {
      type                        = "OWASP"
      version                     = "3.1"
    }
  }

}