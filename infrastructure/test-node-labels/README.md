<!-- markdownlint-disable MD033 -->
# iDesk kubernetes cluster

Create an idesk kubernetes cluster including the NFS server used for product storage.

- [iDesk kubernetes cluster](#idesk-kubernetes-cluster)
  - [Resource group creation](#resource-group-creation)
  - [Cluster deployment](#cluster-deployment)
  - [NFS server deployment](#nfs-server-deployment)
  - [Ping monitor](#ping-monitor)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)

## Resource group creation

First a resource group for the cluster is created which is an input parameter
to the modules being used.

## Cluster deployment

Next a kubernetes cluster is installed in the resource group from the first step, using the [_modules/k8s_](../modules/k8s/README.md).

## NFS server deployment

Then, during installation of the second agent pool an NFS server is provisioned 
with [_modules/nfs_](../modules/nfs/README.md),
using the node resource group created by the kubernetes cluster provisioning, connecting
the local network interface of the NFS server to the only subnet of the virtual network there.
This is done, so the cluster nodes are able to reach the NFS server via a direct network connection.

The NFS server gets a public IP address which via a load balancer is attached to the NFS vm.

An input rule allowing SSH access via the Public IP address is installed in
the network security group also created by cluster provisioning.

The admin account for the NFS server is determined by field _admin\_user_ of the variable [vm](#input_vm).
The public ssh keys of infstructure developers in the Aurora Team are installed such that
those can access the server via _ssh k8sadmin@\<IP address>_ (e.g. for troubleshooting).

The NFS server has two data disks attached:

1. the _products_ disk, mounted to _/data/products_, which is initialized with a copy of the product sync server's disk
   
   (with the last backup of that disk, to be precise)

2. the _apim_ disk, mounted to _/data/apim_, which on a DEV cluster is initialized empty and on the PROD cluster is initialized
   with a copy of the previous prod cluster's apim disk

## Ping monitor

After the kubernetes cluster is done, parallel to the NFS server deployment, the output from the k8s module (host and kubeconfig) are used to create a pod containing a process which pings the kubernetes API server about once in a second.

The output (about 2Mb/h) is written to a dynamic volume mounted on `/monitoring`. That monitor is left running until it either is shut down manually or until the cluster is dismantled.

That output may be used to find network interruptions to the API server during cluster operation.
A similar monitor is started on the build server so we can trace network interruptions and determine if they were cluster internal or an interruption to the Haufe network.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.41.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cluster-resource-group"></a> [cluster-resource-group](#module\_cluster-resource-group) | ../modules/cluster-resource-group | n/a |
| <a name="module_k8s"></a> [k8s](#module\_k8s) | ../modules/k8s | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth"></a> [auth](#input\_auth) | Authentication properties | <pre>object({<br>    admin_user          = string // name of admin user<br>    ssh_public_key_path = string // Path to ssh public key file needed for admin access<br>  })</pre> | n/a | yes |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | cluster properties | <pre>object({<br>    // Name of the cluster<br>    name = string<br>    // Kubernetes version to deploy. Note: the values are restricted by AKS, you can't take arbitrary values<br>    kubernetes_version = string<br>    // agent pool for application components<br>    app_pool = object({<br>      agent_size      = string<br>      agent_count     = number<br>      max_pods        = number<br>      os_disk_size_gb = number<br>      labels          = map(string)<br>    })<br>    // agent pool for monitoring components<br>    monitor_pool = object({<br>      agent_size      = string<br>      agent_count     = number<br>      max_pods        = number<br>      os_disk_size_gb = number<br>      labels          = map(string)<br>    })<br>    // Cluster resource group<br>    group = object({<br>      name     = string // name of the resource group<br>      location = string // location of the resource group - will be used for all server resources<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_creation_properties"></a> [creation\_properties](#input\_creation\_properties) | Creator time/date of creation of the resource | <pre>object({<br>    name = string // name of creator<br>    host = string // host where creation was started<br>  })</pre> | `null` | no |
| <a name="input_kubeconfig"></a> [kubeconfig](#input\_kubeconfig) | path of configuration file for the created k8s cluster | `string` | n/a | yes |
| <a name="input_subscription_properties"></a> [subscription\_properties](#input\_subscription\_properties) | Azure subscription properties | <pre>object({<br>    // Azure subscription to use for creating the cluster, default is hg-az-ppi-idesk-Non-Prod<br>    subscription_id = string<br>    // client id for authentication<br>    client_id = string<br>    // client secret for authentication<br>    client_secret = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | kubernetes cluster configuration |
| <a name="output_node-resource-group"></a> [node-resource-group](#output\_node-resource-group) | node resource group of the cluster |
| <a name="output_resource-group"></a> [resource-group](#output\_resource-group) | main resource group |
<!-- END_TF_DOCS -->
