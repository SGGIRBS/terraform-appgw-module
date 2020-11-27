output "frontend_ip" {
  value       = azurerm_application_gateway.appgw.frontend_ip_configuration[1].private_ip_address
  description = "The private IP address of the frontend."
}

output "gateway_id" {
  value       = azurerm_application_gateway.appgw.id
  description = "The ID of the application gateway."
}