<!-- markdownlint-disable MD033 -->
# Aurora terraform tags configuration

The Haufe azure landing zone requires resources to be tagged with a set of standardized tags. In addition also the Aurora project thinks it to be desirable to have own tags defined which look the same in all resources.

This module provides a set of tag definitions which may be added to azure resources allowing tags to defined.

## Example

  ~~~hcl
  module "tags" {
    source = "../tags"
    creation_properties = var.creation_properties
  }

  resource "azurerm_resource_group" "cluster" {
    name     = var.resource-group.name
    location = var.resource-group.location
    tags     = merge(
      module.tags.aurora_resource_group_tags, {
      (module.tags.tag_keys.k8s_type) = "aks"
    })
  }
  ~~~

<!-- BEGIN_TF_DOCS -->


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_creation_properties"></a> [creation\_properties](#input\_creation\_properties) | Creator time/date of creation of the resource | <pre>object({<br>    // name of creator<br>    name = string<br>    // host where creation was started<br>    host = string<br>  })</pre> | `null` | no |
| <a name="input_service_owner"></a> [service\_owner](#input\_service\_owner) | Owner of all azure resources - to be put into hg-lz-resource-owner label | `string` | `"Aurora"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aurora_disk_tags"></a> [aurora\_disk\_tags](#output\_aurora\_disk\_tags) | Tags for all disks/storage groups used by aurora |
| <a name="output_aurora_owner_without_service_affiliation"></a> [aurora\_owner\_without\_service\_affiliation](#output\_aurora\_owner\_without\_service\_affiliation) | Tags for resources with only owner and service affilitation required |
| <a name="output_aurora_resource_group_tags"></a> [aurora\_resource\_group\_tags](#output\_aurora\_resource\_group\_tags) | Tags for aurora resource groups |
| <a name="output_aurora_vm_tags"></a> [aurora\_vm\_tags](#output\_aurora\_vm\_tags) | tags for VMs created by Aurora |
| <a name="output_tag_aurora_service_affiliation"></a> [tag\_aurora\_service\_affiliation](#output\_tag\_aurora\_service\_affiliation) | Aurora service dependencies (required by azure landing zone) |
| <a name="output_tag_creator"></a> [tag\_creator](#output\_tag\_creator) | Tag showing creator, host as well as date time of resource creation |
| <a name="output_tag_keys"></a> [tag\_keys](#output\_tag\_keys) | Names for keys also used in program code |
| <a name="output_tag_no_service_affiliation"></a> [tag\_no\_service\_affiliation](#output\_tag\_no\_service\_affiliation) | Empty tag for service affiliation (enforced by azure landing zone) |
| <a name="output_tag_owner"></a> [tag\_owner](#output\_tag\_owner) | Tag denoting a resource owner (required by azure landing zone) |
<!-- END_TF_DOCS -->

## implementation files

### tags.tf

This contains variables with values that contain the tags required by the Azure landing zone in Haufe.

See <https://mywiki.grp.haufemg.com/display/SEHAAZGO/Constraints>

### auroratags.tf

This contains tags commonly used in aurora configurations
