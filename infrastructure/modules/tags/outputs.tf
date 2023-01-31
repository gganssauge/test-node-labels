output "tag_creator" {
  description = "Tag showing creator, host as well as date time of resource creation"
  value       = local.tag_creator
}

output "tag_keys" {
  description = "Names for keys also used in program code"
  value = {
    // Name of node resource group that is created by AKS
    node_resource_group = "node_resource_group"
    // Name of the resource group which is passed to the cluster creation
    belongs_to_node_group = "belongs_to_cluster_resource_group"
    // Cluster type: currently always "aks"
    k8s_type = "k8s_type"
    // backup type for the disk ("nfs" or "sync")
    disk_type = "type"
    // id of the VNET carrying the public ips of the cluster
    vnet_id = "aurora-public-vnet-id"
    // id of the NFS server VM
    nfs_id = "aurora-nfs-server-id"
  }
}

output "tag_owner" {
  description = "Tag denoting a resource owner (required by azure landing zone)"
  value       = local.tag_owner
}

output "tag_no_service_affiliation" {
  description = "Empty tag for service affiliation (enforced by azure landing zone)"
  value       = local.tag_no_service_affiliation
}

output "tag_aurora_service_affiliation" {
  description = "Aurora service dependencies (required by azure landing zone)"
  value       = local.tag_aurora_service_affiliation
}

output "aurora_owner_without_service_affiliation" {
  description = "Tags for resources with only owner and service affilitation required"
  value       = local.aurora_owner_without_service_affiliation
}

output "aurora_resource_group_tags" {
  description = "Tags for aurora resource groups"
  value       = local.aurora_resource_group_tags
}

output "aurora_disk_tags" {
  description = "Tags for all disks/storage groups used by aurora"
  value       = local.aurora_disk_tags
}

output "aurora_vm_tags" {
  description = "tags for VMs created by Aurora"
  value       = local.aurora_vm_tags
}
