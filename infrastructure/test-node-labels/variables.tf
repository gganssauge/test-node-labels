variable "cluster" {
  description = "cluster properties"
  type = object({
    // Name of the cluster
    name = string
    // Kubernetes version to deploy. Note: the values are restricted by AKS, you can't take arbitrary values
    kubernetes_version = string
    // agent pool for application components
    app_pool = object({
      agent_size      = string
      agent_count     = number
      max_pods        = number
      os_disk_size_gb = number
      labels          = map(string)
    })
    // agent pool for monitoring components
    monitor_pool = object({
      agent_size      = string
      agent_count     = number
      max_pods        = number
      os_disk_size_gb = number
      labels          = map(string)
    })
    // Cluster resource group
    group = object({
      name     = string // name of the resource group
      location = string // location of the resource group - will be used for all server resources
    })
  })
}

variable "creation_properties" {
  description = "Creator time/date of creation of the resource"
  type = object({
    name = string // name of creator
    host = string // host where creation was started
  })
  default = null
}

variable "subscription_properties" {
  description = "Azure subscription properties"
  sensitive   = true
  type = object({
    // Azure subscription to use for creating the cluster, default is hg-az-ppi-idesk-Non-Prod
    subscription_id = string
    // client id for authentication
    client_id = string
    // client secret for authentication
    client_secret = string
  })
}

variable "auth" {
  description = "Authentication properties"
  type = object({
    admin_user          = string // name of admin user
    ssh_public_key_path = string // Path to ssh public key file needed for admin access
  })
}

variable "kubeconfig" {
  description = "path of configuration file for the created k8s cluster"
  type        = string
}
