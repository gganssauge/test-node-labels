<!-- markdownlint-disable MD033 -->
# Create a kubernetes cluster

This module is responsible for creating a resource group that will host an AKS cluster.
The group has a tag `k8s_type` with value `AKS`. 

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
| [azurerm_resource_group.cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_creation_properties"></a> [creation\_properties](#input\_creation\_properties) | Creator (name/host) of resource creation | <pre>object({<br>    name = string // name of creator<br>    host = string // host where creation was started<br>  })</pre> | `null` | no |
| <a name="input_resource-group"></a> [resource-group](#input\_resource-group) | Resource group to create | <pre>object({<br>    name     = string<br>    location = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource-group"></a> [resource-group](#output\_resource-group) | cluster resource group |
<!-- END_TF_DOCS -->
