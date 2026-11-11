# This is the "blueprint" for our container registry
resource "aws_ecr_repository" "devops_repo" {
  # The name for your repository
  name = "devops-repo"

  # This setting makes sure you can't accidentally overwrite an image tag
  image_tag_mutability = "IMMUTABLE"

  # This block enables vulnerability scanning when you push an image
  image_scanning_configuration {
    scan_on_push = true
  }

  # Tags are good practice for organization
  tags = {
    Environment = "Testing"
    ManagedBy   = "DevOps Class"
  }

  #checkov:skip=CKV_AWS_136: Accepted risk - AES256 default encryption already active, class/testing repo with no sensitive images, customer-managed KMS not justified. Owner Jongkuch Anyar, revisit 2026-12-10.
}

# This "output" block will print the registry's URL after it's created
output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.devops_repo.repository_url
}
