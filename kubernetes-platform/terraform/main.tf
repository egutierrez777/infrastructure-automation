module "load_balancer" {
  source = "./modules/vm"

  vm_name = "k8s-lb01"
  cpu     = var.lb_cpu
  memory  = var.lb_memory

  datacenter = var.datacenter
  host       = var.host
  datastore  = var.datastore
  network    = var.network
  template   = var.template
}

module "control_plane" {
  source = "./modules/vm"

  count = length(var.master_ips)

  vm_name = format("k8s-master%02d", count.index + 1)
  cpu     = var.master_cpu
  memory  = var.master_memory

  datacenter = var.datacenter
  host       = var.host
  datastore  = var.datastore
  network    = var.network
  template   = var.template
}

module "worker" {
  source = "./modules/vm"

  count = length(var.worker_ips)

  vm_name = format("k8s-worker%02d", count.index + 1)
  cpu     = var.worker_cpu
  memory  = var.worker_memory

  datacenter = var.datacenter
  host       = var.host
  datastore  = var.datastore
  network    = var.network
  template   = var.template
}
