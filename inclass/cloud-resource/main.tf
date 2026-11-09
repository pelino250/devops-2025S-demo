terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}


provider "aws" {
  region = "eu-north-1"
}


resource "aws_instance" "my_server" {
  ami           = "ami-0023cab4808f43ac9"
  instance_type = "t3.micro"


  tags = {
    Name = "terraform-first-push"
  }
}


variable "image" {
  type        = string
  description = "Docker Hub image, e.g. youruser/campus-event-notifier:v1"
}

