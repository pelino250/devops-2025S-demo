variable "ssh_public_key_path" {
  description = "Path to the public half of the SSH key used to access the local servers."
  type        = string
  default     = "~/.ssh/alu-devops.pub"
}

variable "docker_socket_path" {
  description = "Docker Desktop/WSL Docker socket path."
  type        = string
  default     = "/var/run/docker.sock"
}

variable "app_ssh_port" {
  description = "Host port used to SSH into the application server."
  type        = number
  default     = 2222
}

variable "db_ssh_port" {
  description = "Host port used to SSH into the database server."
  type        = number
  default     = 2223
}

variable "app_port" {
  description = "Host port where the Campus Event Notifier will be available."
  type        = number
  default     = 8080
}

variable "app_server_host_port" {
  description = "Host port mapped to the Terraform application server."
  type        = number
  default     = 8081
}