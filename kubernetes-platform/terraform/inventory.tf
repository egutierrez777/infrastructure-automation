resource "local_file" "ansible_bootstrap_inventory" {
  filename = "../ansible/inventories/bootstrap/hosts.ini"

  content = templatefile(
    "${path.module}/inventory-bootstrap.tpl",
    {
      load_balancer = {
        vm_name   = module.load_balancer.vm_name
        vm_ip     = module.load_balancer.vm_ip
        static_ip = var.lb_ip
      }


      control_plane = [
        for index, node in module.control_plane : {
          vm_name   = node.vm_name
          vm_ip     = node.vm_ip
          static_ip = var.master_ips[index]
        }
      ]

      workers = [
        for index, node in module.worker : {
          vm_name   = node.vm_name
          vm_ip     = node.vm_ip
          static_ip = var.worker_ips[index]
        }
      ]
    }
  )
}

resource "local_file" "ansible_kubernetes_inventory" {
  filename = "../ansible/inventories/kubernetes/hosts.ini"

  content = templatefile(
    "${path.module}/inventory-kubernetes.tpl",
    {
      load_balancer = {
        vm_name   = module.load_balancer.vm_name
        static_ip = var.lb_ip
      }

      control_plane = [
        for index, node in module.control_plane : {
          vm_name   = node.vm_name
          static_ip = var.master_ips[index]
        }
      ]

      workers = [
        for index, node in module.worker : {
          vm_name   = node.vm_name
          static_ip = var.worker_ips[index]
        }
      ]
    }
  )

  depends_on = [
    terraform_data.ansible_bootstrap
  ]
}
