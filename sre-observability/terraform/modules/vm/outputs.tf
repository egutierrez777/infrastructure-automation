output "name" {
  description = "Created virtual machine name"
  value       = vsphere_virtual_machine.vm.name
}

output "id" {
  description = "Virtual machine UUID"
  value       = vsphere_virtual_machine.vm.id
}

output "ip" {
  description = "Virtual machine IP address"
  value       = vsphere_virtual_machine.vm.default_ip_address
}
