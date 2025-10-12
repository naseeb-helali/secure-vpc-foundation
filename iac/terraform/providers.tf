###############################################################
# providers.tf — Provider and Backend Configuration
# Scope: Phase 1 (Free Tier)
# ------------------------------------------------------------
# This file defines:
# - Required Terraform and provider versions
# - AWS provider configuration
# - (Optional) remote backend template (commented for Phase 2)
###############################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Backend (commented out for now)
  # Uncomment and configure in Phase 2 if you use Terraform Cloud or S3 backend.
  #
  # backend "s3" {
  #   bucket         = "<your-tfstate-bucket>"
  #   key            = "secure-vpc-foundation/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  # }
}

##############################
# AWS Provider
##############################
# Reads credentials from environment variables or shared credentials file:
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
# - AWS_DEFAULT_REGION

provider "aws" {
  region = var.region

  # Optional: specify a profile from ~/.aws/credentials
  # profile = "default"

  default_tags {
    tags = local.common_tags
  }
}
