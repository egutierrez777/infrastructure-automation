output "load_balancer" {
  description = "Kubernetes load balancer"
  value = {
    name = module.load_balancer.vm_name
    ip   = var.lb_ip
  }
}

output "control_plane" {
  description = "Kubernetes control plane nodes"
  value = [
    for index, node in module.control_plane : {
      name = node.vm_name
      ip   = var.master_ips[index]
    }
  ]
}

output "workers" {
  description = "Kubernetes worker nodes"
  value = [
    for index, node in module.worker : {
      name = node.vm_name
      ip   = var.worker_ips[index]
    }
  ]
}
