variable "vcenter_server"   {}
variable "vcenter_user"     {}
variable "vcenter_password" {
  sensitive = true
}
