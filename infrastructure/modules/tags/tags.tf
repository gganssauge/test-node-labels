locals {
  /*
   * tag keys defined by azure landing zone
   */
  // Schedule for auto shutdown
  key_auto_shutdown_schedule = "AutoShutdownSchedule"
  // resource owner tag
  key_owner = "hg-az-lz-resource-owner"
  // List of service affiliations
  key_afilliation = "hg-az-lz-internal-service-affliation"
  // Level of required confidentiality
  key_confidentiality = "hg-az-lz-allowed-data-level"
  // OS running on the VM
  key_osname = "hg-az-lz-osname"
  // Used to determine if the resource requires a backup
  key_backup_required = "hg-az-lz-backup-required"
  // creator, originating machine and date/time of creation
  key_creator = "aurora-creator"

  /*
   * confidentiality levels defined by Azure landing zone
   */

  // This resource contains secret data
  tag_secret = {
    (local.key_confidentiality) = "secret"
  }

  // This resource contains confidential data
  tag_confidential = {
    (local.key_confidentiality) = "confidential"
  }

  // This resource contains internal data
  tag_internal = {
    (local.key_confidentiality) = "internal"
  }

  // This resource contains public data
  tag_public = {
    (local.key_confidentiality) = "public"
  }

  /*
   * tags for VM operating system as defined by Azure landing zone
   */
  // This VM runs linux
  tag_linux_vm = {
    (local.key_osname) = "linux"
  }

  // This VM runs Windows
  tag_windows_vm = {
    (local.key_osname) = "windows"
  }

  /*
   * tags for Backup Required as defined by Azure landing zone
   */
  // This resource does not require a backup
  tag_no_backup_required = {
    (local.key_backup_required) = "no"
  }

  // This resource requires a backup
  tag_backup_required = {
    (local.key_backup_required) = "yes"
  }
}
