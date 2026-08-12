output "lb_name" {
  description = "Load balancer virtual machine name"
  value       = module.lb01.vm_name
}

output "lb_id" {
  description = "Load balancer virtual machine UUID"
  value       = module.lb01.vm_id
}

output "lb_ip" {
  description = "Load balancer virtual machine IP address"
  value       = module.lb01.vm_ip
}

output "web_name" {
  description = "Web server virtual machine name"
  value       = module.web01.vm_name
}

output "web_id" {
  description = "Web server virtual machine UUID"
  value       = module.web01.vm_id
}

output "web_ip" {
  description = "Web server virtual machine IP address"
  value       = module.web01.vm_ip
}

output "work_env" {
  description = "Environment name used by Ansible"
  value       = var.work_env
}
