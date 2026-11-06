variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "owner" {
  type = string
}

variable "my_ip_cidr" {
  type = string
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/campus_notifier.pub"
}

variable "private_key_path" {
  type    = string
  default = "~/.ssh/campus_notifier"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
