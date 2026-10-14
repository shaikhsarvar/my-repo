output "application_gateway_id" {
  value = azurerm_application_gateway.appgw.id
}

output "public_ip" {
  value = azurerm_public_ip.appgw.ip_address
}

output "private_ip_address" {
  value = [
    for frontend in azurerm_application_gateway.appgw.frontend_ip_configuration :
    frontend.private_ip_address
    if frontend.name == "frontend-ip-private"
  ][0]
}
