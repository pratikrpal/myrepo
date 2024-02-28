output "app_service_url" {
  value = azurerm_linux_web_app.app_service.default_hostname
}
output "app_service_id" {
  value = azurerm_linux_web_app.app_service.id
}

output "vm_details" {
  value = [
    for vm in azurerm_linux_virtual_machine.testvm : {
      id                 = vm.id,
      name               = vm.name,
      private_ip_address = "${azurerm_network_interface.vm_nic[0].private_ip_address}"
    }
  ]
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "sql_database_name" {
  value = azurerm_mssql_database.sql_database.id
}