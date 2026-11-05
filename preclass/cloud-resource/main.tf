# Create an S3 bucket for the AWS resource provisioning lab.
resource "aws_s3_bucket" "tf_state" {
  bucket = "yankee-dev-tf-state-emery-20261103"

  tags = {
    Name      = "yankee-dev-tf-state-emery-20261103"
    ManagedBy = "Terraform"
  }
}

output "bucket_name" {
  description = "The name of the S3 bucket created for this lab."
  value       = aws_s3_bucket.tf_state.bucket
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
