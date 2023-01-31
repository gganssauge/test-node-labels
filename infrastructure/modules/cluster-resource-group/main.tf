provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  features {}
}

module "tags" {
  source              = "../tags"
  creation_properties = var.creation_properties
}

resource "azurerm_resource_group" "cluster" {
  name     = var.resource-group.name
  location = var.resource-group.location
  tags = merge(
    // the k8s_type tag is used backup jobs
    // to establish that the group with the
    // disks to backup is the node resource group for
    // this.
    module.tags.aurora_resource_group_tags, {
      (module.tags.tag_keys.k8s_type) = "AKS"
  })

  lifecycle {
    ignore_changes = [
      tags // there are tags added behind the scenes via an azure policy
    ]
  }
}
