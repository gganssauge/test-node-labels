provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.41.0"
    }
  }
}

resource "azurerm_resource_group" "cluster" {
  name     = var.resource-group.name
  location = var.resource-group.location
  tags     = {
    hg-az_lz-resource-owner              = "Aurora"
    hg-az_lz-internal-service-afiliation = ""
  }

  lifecycle {
    ignore_changes = [
      tags // there are tags added behind the scenes via an azure policy
    ]
  }
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "TEST"
  resource_group_name = azurerm_resource_group.cluster.name
  location            = azurerm_resource_group.cluster.location
  kubernetes_version  = "1.25"

  default_node_pool {
    name        = "agentpool"
    vm_size     = "Standard_B2s"
    node_count  = var.agent-count
    node_labels = {
      stack = "app"
    }
    tags = local.vm_tags
  }

  dns_prefix = "test-node-labels"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    hg-az_lz-resource-owner = "Aurora"
  }

  lifecycle {
    //noinspection HILUnresolvedReference
    ignore_changes = [
      default_node_pool[0].tags,
      tags // there are tags added behind the scenes
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "monitor" {
  name                  = "monitor"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = "Standard_B2s"
  node_count            = var.agent-count
  node_labels           = {
    stack = "monitoring"
  }
  tags = local.vm_tags

  lifecycle {
    ignore_changes = [
      tags // there are tags added behind the scenes
    ]
  }
}

output "kubeconfig" {
  description = "kubernetes cluster configuration"
  value       = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive   = true
}

variable "agent-count" {
  description = "Number of agents per pool"
  type        = number
}

variable "resource-group" {
  description = "cluster resource group"
  type        = object({
    name     = string // name of the resource group
    location = string // location of the resource group - will be used for all server resources
  })
}

locals {
  vm_tags = {
    hg-az_lz-resource-owner              = "Aurora"
    hg-az_lz-osname                      = "linux"
    hg-az_lz-internal-service-afiliation = ""
    hg-az_lz-backup-required             = "no"
    hg-az_lz-allowed-data-level          = "confidential"
    AutoShutdownSchedule                 = "00:00 -> 00:00"
  }
}
