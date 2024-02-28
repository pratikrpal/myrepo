/*
terraform {
  backend "azurerm" {
    resource_group_name    = "statefile-rg"
    storage_account_name   = "statefilestorageaccount"
    storage_container_name = "statefilecontainer"
    key                    = "vm-statefile.tfstate"
  }
}
*/