module "web" {
  source      = "./modules/vm"

  name        = var.name
  cpu         = var.cpu
  memory      = var.memory

  datacenter  = var.datacenter
  host        = var.host
  datastore   = var.datastore
  network     = var.network
  template    = var.template
}

module "monitoring" {
  source      = "./modules/vm"

  name        = var.mon_name
  cpu         = var.mon_cpu
  memory      = var.mon_memory

  datacenter  = var.datacenter
  host        = var.host
  datastore   = var.datastore
  network     = var.network
  template    = var.template 
}
