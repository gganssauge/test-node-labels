<!-- markdownlint-disable MD033 -->
# Create a kubernetes cluster

This module is responsible for creating an AKS cluster in a given resource group.

## Development

The `terraform.tfvars.template` is there for isolated testing of the module. It is not required
for normal usage of the module.

It is intended to be a template for the `template-yamls.sh` script
(see [aurora.k8s.deploy.env](ssh://git@gitlab.haufedev.systems:2222/aurora/infrastructure/aurora.k8s.deploy.env)).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.14.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.14.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tags"></a> [tags](#module\_tags) | ../tags | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.k8s](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.monitor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster"></a> [cluster](#input\_cluster) | n/a | <pre>object({<br>    // Name of the cluster<br>    name = string<br>    // Kubernetes version to deploy. Note: the values are restricted by AKS, you can't take arbitrary values<br>    kubernetes_version = string<br>    // agent pool for application components<br>    app_pool = object({<br>      agent_size      = string<br>      agent_count     = number<br>      max_pods        = number<br>      os_disk_size_gb = number<br>      labels          = map(string)<br>    })<br>    // agent pool for monitoring components<br>    monitor_pool = object({<br>      agent_size      = string<br>      agent_count     = number<br>      max_pods        = number<br>      os_disk_size_gb = number<br>      labels          = map(string)<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_creation_properties"></a> [creation\_properties](#input\_creation\_properties) | Creator time/date of creation of the resource | <pre>object({<br>    name = string // name of creator<br>    host = string // host where creation was started<br>  })</pre> | `null` | no |
| <a name="input_resource-group"></a> [resource-group](#input\_resource-group) | Resource group to create | <pre>object({<br>    name     = string<br>    location = string<br>  })</pre> | n/a | yes |
| <a name="input_ssh-auth"></a> [ssh-auth](#input\_ssh-auth) | properties of the ssh admin connection | <pre>object({<br>    // admin user<br>    admin_user = string<br>    // Path of the ssh public key which will be stored in authorized_keys on the cluster<br>    public_key_path = string<br>  })</pre> | n/a | yes |
| <a name="input_subscription_properties"></a> [subscription\_properties](#input\_subscription\_properties) | Azure subscription properties | <pre>object({<br>    // Azure subscription to use for creating the cluster, default is hg-az-ppi-idesk-Non-Prod<br>    subscription_id = string<br>    // client id for authentication<br>    client_id = string<br>    // client secret for authentication<br>    client_secret = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster"></a> [cluster](#output\_cluster) | kubernetes cluster instance |
| <a name="output_host"></a> [host](#output\_host) | DNS name of the cluster |
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | cluster configuration |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | kubernetes cluster configuration |
<!-- END_TF_DOCS -->
