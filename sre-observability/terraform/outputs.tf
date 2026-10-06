output "web_name" {
  description = "Web server virtual machine name"
  value       = module.web.name
}

output "web_id" {
  description = "Web server virtual machine UUID"
  value       = module.web.id
}

output "web_ip" {
  description = "Web server virtual machine IP address"
  value       = module.web.ip
}

output "mon_name" {
  description = "Monitoring virtual machine name"
  value       = module.monitoring.name
}

output "mon_id" {
  description = "Monitoring virtual machine UUID"
  value       = module.monitoring.id
}

output "mon_ip" {
  description = "Monitoring virtual machine IP address"
  value       = module.monitoring.ip
}

