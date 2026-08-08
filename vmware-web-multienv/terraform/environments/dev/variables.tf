variable "vsphere_server" {
  description = "vCenter Server"
  type        = string
}

variable "vsphere_user" {
  description = "vCenter user"
  type        = string
}

variable "vsphere_password" {
  description = "vCenter password"
  type        = string
  sensitive   = true
}

###
variable "vm_name" {
  description = "Virtual machine name"
  type        = string
}

variable "cpu" {
  description = "Number of vCPU"
  type        = number
}

variable "memory" {
  description = "Number of RAM memory in MB"
  type        = number
}

###
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
  description = "Virtual Network"
  type        = string
}

variable "template" {
  description = "Virtual machine template"
  type        = string
}
