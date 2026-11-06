resource "aws_ecr_repository" "devops_repo" {
  name         = "devops-repo-${lower(var.owner)}"
  force_delete = true
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "campus-notifier-${lower(var.owner)}"
  public_key = file(pathexpand(var.public_key_path))
}

resource "aws_security_group" "app" {
  name = "campus-notifier-${lower(var.owner)}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.app.id]
  tags = {
    Name = "campus-notifier-${lower(var.owner)}"
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = <<-EOT
    [app]
    campus-notifier ansible_host=${aws_instance.app.public_ip}

    [app:vars]
    ansible_user=ubuntu
    ansible_ssh_private_key_file=${pathexpand(var.private_key_path)}
  EOT
}
