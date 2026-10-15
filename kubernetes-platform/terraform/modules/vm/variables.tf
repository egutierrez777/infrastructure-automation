variable "vm_name" {
  description = "Virtual machine name"
  type        = string
}

variable "cpu" {
  description = "Number of vCPUs"
  type        = number
}

variable "memory" {
  description = "Memory in MB"
  type        = number
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
  description = "Virtual network"
  type        = string
}

variable "template" {
  description = "VM template"
  type        = string
}
