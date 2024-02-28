locals {
  tags = {
    environment = "test"
    billing     = "xyz"
    owner       = "Pratik"
    created     = formatdate("DD MM YYYY hh:mm zzz", timestamp())
  }
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network and Subnets
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet1" {
  name                 = var.presentation_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "webapp-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "subnet2" {
  name                 = var.application_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "subnetlb" {
  name                 = var.lb_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "subnet3" {
  name                 = var.application_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/24"]
}

# Network Security Groups
resource "azurerm_network_security_group" "nsg1" {
  name                = var.presentation_nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet_network_security_group_association" "sub1" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_network_security_group" "nsg2" {
  name                = var.application_nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet_network_security_group_association" "sub2" {
  subnet_id                 = azurerm_subnet.subnet2.id
  network_security_group_id = azurerm_network_security_group.nsg2.id
}

resource "azurerm_network_security_group" "nsg3" {
  name                = var.data_nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet_network_security_group_association" "sub3" {
  subnet_id                 = azurerm_subnet.subnet3.id
  network_security_group_id = azurerm_network_security_group.nsg3.id
}

# Azure App Service with App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "P1v2"
}


resource "azurerm_linux_web_app" "app_service" {
  name                = var.app_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {}

}

resource "azurerm_app_service_virtual_network_swift_connection" "example" {
  app_service_id = azurerm_linux_web_app.app_service.id
  subnet_id      = azurerm_subnet.subnet1.id
}

# Azure Virtual Machine with Availability Set and Internal Load Balancer
resource "azurerm_availability_set" "availability_set" {
  name                         = var.availability_set.name
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  managed                      = true
  platform_update_domain_count = var.availability_set.update_domain_count
  platform_fault_domain_count  = var.availability_set.fault_domain_count
}

resource "azurerm_network_interface" "vm_nic" {
  count               = var.vm.count
  name                = "${var.vm.name}-nic-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig${count.index}"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "testvm" {
  count                 = var.vm.count
  name                  = "${var.vm.name}-${count.index + 1}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm.size
  availability_set_id   = azurerm_availability_set.availability_set.id
  network_interface_ids = [azurerm_network_interface.vm_nic[count.index].id] 

  admin_username = var.vm.adminuser
  admin_ssh_key {
    username   = var.vm.adminuser
    public_key = tls_private_key.ssh.public_key_openssh
  }

  os_disk {
    caching              = var.vm_os_disk.caching
    storage_account_type = var.vm_os_disk.type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  disable_password_authentication = true

  tags = merge(local.tags, var.vm_tags)
}

resource "azurerm_lb" "internal" {
  name                = var.lb.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.lb.sku

  frontend_ip_configuration {
    name                          = var.lb.lb_frontend_name
    subnet_id                     = azurerm_subnet.subnetlb.id
    private_ip_address_allocation = "Static"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name            = var.lb.backend_pool_name
  loadbalancer_id = azurerm_lb.internal.id
}


resource "azurerm_network_interface_backend_address_pool_association" "backend_pool_association" {
  count                   = var.vm.count
  network_interface_id    = element(azurerm_network_interface.vm_nic.*.id, count.index + 1)
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}


# Azure SQL Database
resource "azurerm_mssql_server" "sql_server" {
  name                         = var.sql_server.name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = var.sql_server.server_version
  administrator_login          = var.sql_server.adminuser
  administrator_login_password = var.sql_server.admin_password

  azuread_administrator {
    login_username              = "myuserid"
    object_id                   = "11111111-1111-1111-1111-111111111111"
    azuread_authentication_only = true
  }
  tags = local.tags
}

resource "azurerm_mssql_virtual_network_rule" "example" {
  name      = "sql-vnet-rule"
  server_id = azurerm_mssql_server.sql_server.id
  subnet_id = azurerm_subnet.subnet3.id
}

resource "azurerm_mssql_database" "sql_database" {
  name      = var.sql_server.database_name
  server_id = azurerm_mssql_server.sql_server.id
  sku_name  = var.sql_server.database_sku_name


  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}