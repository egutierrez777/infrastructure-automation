resource "local_file" "ansible_inventory" {
  filename = "../../../ansible/inventories/dev/hosts.ini"

  content = templatefile(
    "${path.module}/inventory.tpl",
    {
      vm_name   = module.web01.vm_name
      vm_ip     = module.web01.vm_ip
      work_env  = var.work_env
    }
  )
}
