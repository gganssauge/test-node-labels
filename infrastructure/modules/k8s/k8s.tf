resource "azurerm_kubernetes_cluster" "k8s" {
  #checkov:skip=CKV_AZURE_4:We don't need AKS logging in order to save costs
  #checkov:skip=CKV_AZURE_6:Working from home office makes it impractible to define IP ranges for access to the cluster
  #checkov:skip=CKV_AZURE_7:Not sure what this is about
  #checkov:skip=CKV_AZURE_115:No private network available
  #checkov:skip=CKV_AZURE_116:Not sure about the implications
  #checkov:skip=CKV_AZURE_117:Not sure about the implications
  #checkov:skip=CKV_AZURE_141:Ensure AKS local admin account is disabled

  name                = var.cluster.name
  resource_group_name = local.resource_group_name
  location            = local.location
  dns_prefix          = var.cluster.name
  kubernetes_version  = var.cluster.kubernetes_version
  sku_tier            = local.sku_tier

  linux_profile {
    admin_username = var.ssh-auth.admin_user
    ssh_key {
      key_data = sensitive(file(var.ssh-auth.public_key_path))
    }
  }

  default_node_pool {
    name            = "agentpool"
    vm_size         = var.cluster.app_pool.agent_size
    node_count      = var.cluster.app_pool.agent_count
    max_pods        = var.cluster.app_pool.max_pods
    os_disk_size_gb = var.cluster.app_pool.os_disk_size_gb
    node_labels     = var.cluster.app_pool.labels
    tags            = module.tags.aurora_vm_tags
  }

  service_principal {
    client_id     = var.subscription_properties.client_id
    client_secret = var.subscription_properties.client_secret
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet"
  }

  # Enable Role Based Access Control
  role_based_access_control_enabled = true

  tags = module.tags.aurora_owner_without_service_affiliation

  provisioner "local-exec" {
    /*
     * Add tags to the node resource group, linking the node resource group to the cluster resource group
     * and to set the service affiliation.
     * This is not possible using terraform (at least not in one go), as the node resource group
     * is not known to terraform before the cluster has been created.
     *
     * Unfortunately the id of the node resource group is not available on the cluster and using a datasource
     * introduces a cycle, so we must build the id "by foot".
     */
    command = <<EOT
       az tag update --resource-id "/subscriptions/${local.subscription_id}/resourceGroups/${self.node_resource_group}" \
          --operation merge \
          --tags \
            "${local.affiliation}" \
            "${local.belongs_to}"
       az tag update --resource-id "${local.resource_group_id}" \
          --operation merge \
          --tags \
            "${module.tags.tag_keys.node_resource_group}=${self.node_resource_group}"
    EOT
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
  count                 = var.cluster.monitor_pool.agent_count > 0 ? 1 : 0
  name                  = "monitor"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = var.cluster.monitor_pool.agent_size
  node_count            = var.cluster.monitor_pool.agent_count
  max_pods              = var.cluster.monitor_pool.max_pods
  os_disk_size_gb       = var.cluster.monitor_pool.os_disk_size_gb
  node_labels           = var.cluster.monitor_pool.labels
  tags                  = module.tags.aurora_vm_tags

  lifecycle {
    ignore_changes = [
      tags // there are tags added behind the scenes
    ]
  }
}

locals {
  # name of the resource group actually created
  resource_group_name = var.resource-group.name
  # location of the resource group actually created
  location = var.resource-group.location
  # id of the subscription used
  subscription_id = var.subscription_properties.subscription_id
  # Availability must be paid, see https://docs.microsoft.com/de-de/azure/aks/uptime-sla
  sku_tier = "Paid"
  # resource group id for the cluster resource group
  resource_group_id = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}"

  affiliation = join(" ", [for k, v in module.tags.tag_aurora_service_affiliation : "${k}=${v}"])
  belongs_to  = "${(module.tags.tag_keys.belongs_to_node_group)}=\"${local.resource_group_name}\""
}
