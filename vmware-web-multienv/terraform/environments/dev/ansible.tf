resource "terraform_data" "ansible" {
  depends_on = [
    local_file.ansible_inventory
  ]

  triggers_replace = [
    module.web01.vm_ip
  ]

  provisioner "local-exec" {
    working_dir = "${path.module}/../../../ansible"

    command = <<-EOT
      ansible-playbook playbooks/main.yaml
    EOT
  }
}
