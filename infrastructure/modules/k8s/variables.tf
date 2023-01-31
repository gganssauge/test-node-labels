variable "creation_properties" {
  description = "Creator time/date of creation of the resource"
  type = object({
    name = string // name of creator
    host = string // host where creation was started
  })
  default = null
}

variable "resource-group" {
  description = "Resource group to create"
  type = object({
    name     = string
    location = string
  })
}

variable "cluster" {
  // cluster parameters
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
  })
}

variable "ssh-auth" {
  description = "properties of the ssh admin connection"
  type = object({
    // admin user
    admin_user = string
    // Path of the ssh public key which will be stored in authorized_keys on the cluster
    public_key_path = string
  })
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
