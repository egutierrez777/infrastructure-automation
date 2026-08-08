variable "vm_name" {
  description = "Virtual machine name"
  type        = string
}

variable "cpu" {
  description = "Number of vCPUs"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 4096
}

variable "datacenter" {
  description = "vSphere datacenter"
  type        = string
}

variable "host" {
  description = "ESXi host"
  type        = string
}

variable "datastore" {
  description = "Virtual machine datastore"
  type        = string
}

variable "network" {
  description = "Virtual machine network"
  type        = string
}

variable "template" {
  description = "Virtual machine template"
  type        = string
}
