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
