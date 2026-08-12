module "lb01" {
  source = "../../modules/vm"

  vm_name = var.lb_vm_name
  cpu     = var.lb_cpu
  memory  = var.lb_memory

  datacenter = var.datacenter
  host       = var.host
  datastore  = var.datastore
  network    = var.network
  template   = var.template
}

module "web01" {
  source = "../../modules/vm"

  vm_name = var.web_vm_name
  cpu     = var.web_cpu
  memory  = var.web_memory

  datacenter = var.datacenter
  host       = var.host
  datastore  = var.datastore
  network    = var.network
  template   = var.template
}
