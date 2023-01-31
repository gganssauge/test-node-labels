locals {
  // Tag denoting a resource owner (required by azure landing zone)
  tag_owner = {
    (local.key_owner) = var.service_owner
  }

  tag_creator = try(
    {
      (local.key_creator) = format(
        "Created in %s by %s on %s",
        timestamp(),
        var.creation_properties.name,
        var.creation_properties.host
      )
    },
  {})

  // Empty tag for service affiliation (enforced by azure landing zone)
  tag_no_service_affiliation = {
    (local.key_afilliation) = "\"\""
  }

  // Aurora service dependencies (required by azure landing zone)
  tag_aurora_service_affiliation = {
    (local.key_afilliation) = "FoundationalServices,ECOM,ContentHub,HaufeOnlinetraining"
  }

  // Tags for aurora resource groups
  aurora_resource_group_tags = merge(
    local.tag_owner,
    local.tag_aurora_service_affiliation,
    local.tag_creator
  )

  // Tags for resources with only owner and service affilitation required
  aurora_owner_without_service_affiliation = merge(
    local.tag_owner,
    local.tag_no_service_affiliation,
    local.tag_creator
  )

  // Tags for all disks/storage groups used by aurora
  aurora_disk_tags = merge(
    local.aurora_owner_without_service_affiliation,
    local.tag_confidential,
    local.tag_no_backup_required,
    local.tag_creator
  )

  // tags for VMs created by Aurora
  aurora_vm_tags = merge(
    local.aurora_owner_without_service_affiliation,
    local.tag_confidential,
    local.tag_no_backup_required,
    local.tag_linux_vm,
    local.tag_creator,
    {
      (local.key_auto_shutdown_schedule) = "0:00->0:00"
    }
  )
}
