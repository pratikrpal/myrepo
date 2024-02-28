resource_group_name      = "example-rg"
location                 = "East US"
vnet_name                = "example-vnet"
vnet_address_space       = ["10.0.0.0/16"]
presentation_subnet_name = "presentation-subnet"
application_subnet_name  = "application-subnet"
lb_subnet_name           = "lb-subnet"
data_subnet_name         = "data-subnet"
presentation_nsg_name    = "presentation-nsg"
application_nsg_name     = "application-nsg"
data_nsg_name            = "data-nsg"
app_service_plan_name    = "example-app-service-plan"
app_service_plan_tier    = "Standard"
app_service_plan_size    = "S1"
app_service_name         = "example-app-service"

vm = {
  count     = 3
  name      = "example-vm"
  size      = "Standard_D2s_v3"
  adminuser = "adminusr"
}

vm_os_disk = {
  caching = "ReadWrite"
  type    = "Standard_LRS"
}

availability_set = {
  name                = "example-availability-set"
  update_domain_count = 5
  fault_domain_count  = 3
}

vm_tags = { environment = "test" }

lb = {
  name              = "internal-lb"
  sku               = "Standard"
  backend_pool_name = "test-backend-pool"
  lb_frontend_name  = "test-frontend"
}


sql_server = {
  name              = "tes-sql-server"
  server_version    = "12.0"
  adminuser         = "adminuser"
  admin_password    = "Password1234!"
  database_name     = "test-sql-db"
  database_sku_name = "S0"
}
