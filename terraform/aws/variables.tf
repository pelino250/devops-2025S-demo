variable "aws_region" {
  type        = string
  description = "AWS region for the lab resources"
  default     = "us-east-1"
}

variable "my_ip_cidr" {
  type        = string
  description = "Your current public IPv4 address in CIDR form, for example 203.0.113.10/32"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the public half of the lab SSH key"
  default     = "~/.ssh/alu-devops.pub"
}

variable "instance_type" {
  type        = string
  description = "Small EC2 instance type for the lab servers"
  default     = "t3.micro"
}

variable "app_port" {
  type        = number
  description = "Public port for the Campus Notifier app"
  default     = 8000
}
