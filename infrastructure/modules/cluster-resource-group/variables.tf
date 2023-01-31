variable "creation_properties" {
  description = "Creator (name/host) of resource creation"
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
