provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  features {}
}

provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  features {}
  alias           = "prod"
  subscription_id = var.subscription_properties.subscription_id
}

module "cluster-resource-group" {
  // create a resource group for the cluster
  source              = "../modules/cluster-resource-group"
  resource-group      = var.cluster.group
  creation_properties = var.creation_properties
}

module "k8s" {
  // Setup the Kubernetes cluster
  source                  = "../modules/k8s"
  subscription_properties = var.subscription_properties
  cluster = {
    name = var.cluster.name
    // Kubernetes version to deploy. Note: the values are restricted by AKS, you can't take arbitrary values
    kubernetes_version = var.cluster.kubernetes_version
    // agent pool for application components
    app_pool = var.cluster.app_pool
    // agent pool for monitoring components
    monitor_pool = var.cluster.monitor_pool
  }

  resource-group = module.cluster-resource-group.resource-group

  creation_properties = var.creation_properties
}
