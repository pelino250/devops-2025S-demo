output "instance_public_ip" {
  description = "Public IPv4 address of the app server"
  value       = aws_instance.app.public_ip
}

output "instance_private_ip" {
  description = "Private IPv4 address of the app server"
  value       = aws_instance.app.private_ip
}

output "ssh_user" {
  description = "Default SSH user for Ubuntu 24.04"
  value       = "ubuntu"
}

output "app_port" {
  description = "Public HTTP port for the app"
  value       = var.app_port
}

output "db_public_ip" {
  description = "Public IPv4 address of the database server"
  value       = aws_instance.db.public_ip
}

output "db_private_ip" {
  description = "Private IPv4 address of the database server"
  value       = aws_instance.db.private_ip
}

output "db_ssh_port" {
  description = "SSH port for the database server"
  value       = 22
}
