terraform {
  cloud {
    organization = "igornoel"

    workspaces {
      name = "igornoel-workspace"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  #checkov:skip=CKV_AWS_394: This single-AZ class lab uses the first available zone for account portability and does not claim multi-AZ resilience.
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "lab" {
  #checkov:skip=CKV2_AWS_11: This short-lived class lab has no sensitive workload; flow logs add CloudWatch cost and must be enabled before production use.
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "campus-notifier-lab"
    Purpose = "Week 4 Pre-Class 2"
  }
}

resource "aws_default_security_group" "lab" {
  vpc_id = aws_vpc.lab.id

  ingress = []
  egress  = []

  tags = {
    Name = "campus-notifier-default-restricted"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "campus-notifier-public"
  }
}

resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "campus-notifier-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }

  tags = {
    Name = "campus-notifier-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_key_pair" "lab" {
  key_name   = "campus-notifier-lab"
  public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
}

resource "aws_security_group" "app" {
  name        = "campus-notifier-app"
  description = "SSH and app access from the current client IP"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "SSH from the current client IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "Campus Notifier web app from the current client IP"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    description = "HTTPS for package repositories and ECR image pulls"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS lookups for package repositories and ECR"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "TCP DNS lookups for package repositories and ECR"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "campus-notifier-app"
  }
}

resource "aws_security_group" "db" {
  name        = "campus-notifier-db"
  description = "SSH from the current client IP and PostgreSQL from the app server only"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "SSH from the current client IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description     = "PostgreSQL from the app server"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "HTTPS for package repositories"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS lookups for package repositories"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "TCP DNS lookups for package repositories"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "campus-notifier-db"
  }
}

resource "aws_instance" "app" {
  #checkov:skip=CKV_AWS_88: A public endpoint is required for this lab app; ingress is limited to the student's configured client IP CIDR.
  #checkov:skip=CKV_AWS_126: Detailed monitoring adds cost; this low-budget class lab uses basic monitoring and must enable detailed monitoring before production.
  #checkov:skip=CKV2_AWS_41: The guest makes no AWS API calls; an instance role would grant unused AWS permissions.
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  key_name                    = aws_key_pair.lab.key_name
  associate_public_ip_address = true
  ebs_optimized               = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
  }

  tags = {
    Name    = "campus-notifier-app"
    Purpose = "Week 4 Pre-Class 2"
  }
}

resource "aws_instance" "db" {
  #checkov:skip=CKV_AWS_88: Direct SSH access is part of this short-lived lab; the security group restricts ingress to the student's configured client IP CIDR.
  #checkov:skip=CKV_AWS_126: Detailed monitoring adds cost; this low-budget class lab uses basic monitoring and must enable detailed monitoring before production.
  #checkov:skip=CKV2_AWS_41: The guest makes no AWS API calls; an instance role would grant unused AWS permissions.
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.db.id]
  key_name                    = aws_key_pair.lab.key_name
  associate_public_ip_address = true
  ebs_optimized               = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
  }

  tags = {
    Name    = "campus-notifier-db"
    Purpose = "Week 4 Pre-Class 2"
  }
}
