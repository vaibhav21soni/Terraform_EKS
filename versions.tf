terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

  # S3 backend with workspace support
  # Note: Update the bucket name and region according to your setup
  # backend "s3" {
  #   bucket         = "terraform-state-eks-infrastructure"
  #   key            = "eks-infrastructure/terraform.tfstate"
  #   region         = "us-west-2"
  #   dynamodb_table = "terraform-locks-eks"
  #   encrypt        = true
    
  #   # Workspace support - each workspace gets its own state file
  #   workspace_key_prefix = "workspaces"
  # }
}
