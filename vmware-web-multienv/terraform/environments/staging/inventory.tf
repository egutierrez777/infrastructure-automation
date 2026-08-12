resource "local_file" "ansible_inventory" {
  filename = "../../../ansible/inventories/staging/hosts.ini"

  content = templatefile(
    "${path.module}/inventory.tpl",
    {
      lb_name  = module.lb01.vm_name
      lb_ip    = module.lb01.vm_ip
      web_name = module.web01.vm_name
      web_ip   = module.web01.vm_ip
      work_env = var.work_env
    }
  )
}
