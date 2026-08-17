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

#############################################
variable "lb_vm_name" {
  description = "Load balancer virtual machine name"
  type        = string
}

variable "lb_cpu" {
  description = "Load balancer number of vCPUs"
  type        = number
}

variable "lb_memory" {
  description = "Load balancer memory in MB"
  type        = number
}

###
variable "web_vm_name" {
  description = "Web server Virtual machine name prefix"
  type        = string
}

variable "web_vm_count" {
  description = "Number of web servers to create"
  type        = number

  validation {
    condition     = var.web_vm_count >= 1
    error_message = "web_vm_count must be at least 1."
  }
}

variable "web_cpu" {
  description = "Web server number of vCPUs"
  type        = number
}

variable "web_memory" {
  description = "Web server memory in MB"
  type        = number
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

##############################################
variable "work_env" {
  description = "Environment name used by Ansible"
  type        = string
}
