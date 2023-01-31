provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  features {}
}

module "tags" {
  source              = "../tags"
  creation_properties = var.creation_properties
}

