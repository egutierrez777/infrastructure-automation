resource "local_file" "ansible_inventory" {
  filename = "../ansible/inventories/prod/hosts.ini"

  content = templatefile(
    "${path.module}/inventory.tpl",
    {
      vm_name   = module.web.name
      vm_ip     = module.web.ip
      mon_name  = module.monitoring.name
      mon_ip    = module.monitoring.ip
    }
  )
}
