output "vm_name" {
  description = "Created virtual machine name"
  value       = module.web01.vm_name
}

output "vm_id" {
  description = "Virtual machine UUID"
  value       = module.web01.vm_id
}

output "vm_ip" {
  description = "Virtual machine IP address"
  value       = module.web01.vm_ip
}

output "work_env" {
  description = "Environment name used by Ansible"
  value       = var.work_env
}
