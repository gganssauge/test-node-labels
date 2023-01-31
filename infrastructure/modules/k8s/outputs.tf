output "kubeconfig" {
  description = "kubernetes cluster configuration"
  value       = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive   = true
}

output "kube_config" {
  description = "cluster configuration"
  value       = azurerm_kubernetes_cluster.k8s.kube_config
  sensitive   = true
}

output "host" {
  description = "DNS name of the cluster"
  value       = azurerm_kubernetes_cluster.k8s.kube_config.0.host
}

output "cluster" {
  description = "kubernetes cluster instance"
  value       = azurerm_kubernetes_cluster.k8s
  sensitive   = true
}
