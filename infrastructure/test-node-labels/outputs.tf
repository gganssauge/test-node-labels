output "resource-group" {
  description = "main resource group"
  value       = module.cluster-resource-group.resource-group
}

output "node-resource-group" {
  description = "node resource group of the cluster"
  value       = module.k8s.cluster.node_resource_group
  // For some reason this needs to be sensitive - otherwise terraform refuses to work
  sensitive = true
}

output "kubeconfig" {
  description = "kubernetes cluster configuration"
  value       = module.k8s.kubeconfig
  sensitive   = true
}
