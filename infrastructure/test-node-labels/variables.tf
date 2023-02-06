variable "agent-count" {
  description = "Number of agents per pool"
  type        = number
}

variable "resource-group" {
  description = "cluster resource group"
  type        = object({
    name     = string // name of the resource group
    location = string // location of the resource group - will be used for all server resources
  })
}
