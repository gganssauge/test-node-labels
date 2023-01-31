variable "service_owner" {
  description = "Owner of all azure resources - to be put into hg-lz-resource-owner label"
  type        = string
  default     = "Aurora"
}

variable "creation_properties" {
  description = "Creator time/date of creation of the resource"
  type = object({
    // name of creator
    name = string
    // host where creation was started
    host = string
  })
  default = null
}
