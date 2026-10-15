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
  description = "Ubuntu VM template"
  type        = string
}

variable "lb_cpu" {
  description = "Number of vCPUs for the Kubernetes load balancer VM"
  type        = number
  default     = 1
}

variable "lb_memory" {
  description = "Memory in MB for the Kubernetes load balancer VM"
  type        = number
  default     = 4092
}

variable "master_cpu" {
  description = "Number of vCPUs per Kubernetes control plane VM"
  type        = number
  default     = 2
}

variable "master_memory" {
  description = "Memory in MB per Kubernetes control plane VM"
  type        = number
  default     = 8192
}

variable "worker_cpu" {
  description = "Number of vCPUs per Kubernetes worker VM"
  type        = number
  default     = 2
}

variable "worker_memory" {
  description = "Memory in MB per Kubernetes worker VM"
  type        = number
  default     = 8192
}

variable "pod_cidr" {
  description = "Kubernetes Pod CIDR"
  type        = string
  default     = "10.244.0.0/16"
}

variable "lb_ip" {
  description = "Static IP for the Kubernetes load balancer"
  type        = string
}

variable "master_ips" {
  description = "Static IPs for Kubernetes masters"
  type        = list(string)
}

variable "worker_ips" {
  description = "Static IPs for Kubernetes workers"
  type        = list(string)
}
