resource "terraform_data" "ansible_bootstrap" {
  depends_on = [
    local_file.ansible_bootstrap_inventory
  ]

  triggers_replace = [
    jsonencode({
      load_balancer = {
        name = module.load_balancer.vm_name
        ip   = var.lb_ip
      }

      control_plane = [
        for index, node in module.control_plane : {
          name = node.vm_name
          ip   = var.master_ips[index]
        }
      ]

      workers = [
        for index, node in module.worker : {
          name = node.vm_name
          ip   = var.worker_ips[index]
        }
      ]
    })
  ]

  provisioner "local-exec" {
    working_dir = "${path.module}/../ansible"

    command = "ansible-playbook -i inventories/bootstrap/hosts.ini playbooks/bootstrap.yaml"
  }
}

resource "terraform_data" "ansible_wait_for_nodes" {
  depends_on = [
    terraform_data.ansible_bootstrap,
    local_file.ansible_kubernetes_inventory
  ]

  provisioner "local-exec" {
    working_dir = "${path.module}/../ansible"

    command = <<-EOT
      ansible all -i inventories/kubernetes/hosts.ini -m ansible.builtin.wait_for_connection -a "timeout=300 sleep=5"
    EOT
  }
}

resource "terraform_data" "ansible_kubernetes" {
  depends_on = [
    terraform_data.ansible_wait_for_nodes
  ]

  triggers_replace = [
    local_file.ansible_kubernetes_inventory.content
  ]

  provisioner "local-exec" {
    working_dir = "${path.module}/../ansible"

    command = "ansible-playbook -i inventories/kubernetes/hosts.ini playbooks/kubernetes.yaml"
  }
}

resource "terraform_data" "ansible_applications" {
  depends_on = [
    terraform_data.ansible_kubernetes
  ]

  triggers_replace = [
    filesha256("${path.module}/../ansible/playbooks/applications.yaml"),
    filesha256("${path.module}/../ansible/roles/applications/defaults/main.yaml"),
    filesha256("${path.module}/../ansible/roles/applications/tasks/main.yaml")
  ]

  provisioner "local-exec" {
    working_dir = "${path.module}/../ansible"

    command = "ansible-playbook -i inventories/kubernetes/hosts.ini playbooks/applications.yaml"
  }
}
