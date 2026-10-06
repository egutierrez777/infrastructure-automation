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

###############################################
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

#############################################
variable "name" {
  description = "Web server Virtual machine name"
  type        = string
}

variable "cpu" {
  description = "Web server number of vCPUs"
  type        = number
}

variable "memory" {
  description = "Web server memory in MB"
  type        = number
}

#######################################
variable "mon_name" {
  description = "Monitoring Virtual machine name"
  type        = string
}

variable "mon_cpu" {
  description = "Monitoring server number of vCPUs"
  type        = number
}

variable "mon_memory" {
  description = "Monitoring server memory in MB"
  type        = number
}
