output "instance_public_ip" {
  description = "Host address used to reach the application server from your laptop."
  value       = "127.0.0.1"
}

output "instance_private_ip" {
  description = "Application server address on the private Docker network."
  value       = docker_container.app_server.network_data[0].ip_address
}

output "ssh_user" {
  description = "SSH username for both local servers."
  value       = "root"
}

output "app_port" {
  description = "Published application port on your laptop."
  value       = var.app_port
}

output "db_public_ip" {
  description = "Host address used to SSH into the database server."
  value       = "127.0.0.1"
}

output "db_private_ip" {
  description = "Database server address on the private Docker network."
  value       = docker_container.db_server.network_data[0].ip_address
}

output "db_ssh_port" {
  description = "Published SSH port for the database server."
  value       = var.db_ssh_port
}

output "app_ssh_port" {
  description = "Published SSH port for the application server."
  value       = var.app_ssh_port
}
