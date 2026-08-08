module "web01" {
  source = "../../modules/vm"

  vm_name     = var.vm_name
  cpu         = var.cpu
  memory      = var.memory

  datacenter  = var.datacenter
  host        = var.host
  datastore   = var.datastore
  network     = var.network
  template    = var.template
}
