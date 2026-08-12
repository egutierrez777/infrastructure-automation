resource "terraform_data" "ansible" {
  depends_on = [
    local_file.ansible_inventory
  ]

  triggers_replace = [
    local_file.ansible_inventory.content
  ]

  provisioner "local-exec" {
    working_dir = "${path.module}/../../../ansible"

    command = <<-EOT
      ansible-playbook -i inventories/staging/hosts.ini playbooks/main.yaml
    EOT
  }
}
