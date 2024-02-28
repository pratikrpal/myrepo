variable "resource_group_name" {
  description = "Name of the resource group"
}

variable "location" {
  description = "Azure region"
  default     = "East US"
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
}

variable "presentation_subnet_name" {
  description = "Name of the Presentation Subnet"
}

variable "application_subnet_name" {
  description = "Name of the Application Subnet"
}

variable "lb_subnet_name" {
  description = "Name of the Data Subnet"
}

variable "data_subnet_name" {
  description = "Name of the Data Subnet"
}

variable "presentation_nsg_name" {
  description = "Name of the Presentation NSG"
}

variable "application_nsg_name" {
  description = "Name of the Application NSG"
}

variable "data_nsg_name" {
  description = "Name of the Data NSG"
}

variable "app_service_plan_name" {
  description = "Name of the App Service Plan"
}

variable "app_service_plan_tier" {
  description = "Tier of the App Service Plan"
}

variable "app_service_plan_size" {
  description = "Size of the App Service Plan"
}

variable "app_service_name" {
  description = "Name of the App Service"
}

variable "vm" {
  description = "details of the Virtual Machine"
  type = object({
    count     = number
    name      = string
    size      = string
    adminuser = string
  })
}

variable "vm_os_disk" {
  description = "Virtual Machine OS disk details"
  type = object({
    caching = string
    type    = string
  })
}

variable "availability_set" {
  description = "availability set details"
  type = object({
    name                = string
    update_domain_count = number
    fault_domain_count  = number
  })
}


variable "vm_tags" {
  description = "Tags for the VM"
  type        = map(string)
}

variable "lb" {
  description = "availability set details"
  type = object({
    name              = string
    sku               = string
    backend_pool_name = string
    lb_frontend_name  = string
  })
}

variable "sql_server" {
  description = "SQL database details"
  type = object({
    name              = string
    server_version    = string
    adminuser         = string
    admin_password    = string
    database_name     = string
    database_sku_name = string
  })
}
