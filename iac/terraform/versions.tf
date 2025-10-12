###############################################################
# versions.tf — Terraform and Provider Version Pinning
# Scope: Phase 1 (Free Tier)
# ------------------------------------------------------------
# Defines required Terraform and provider versions.
# Keeps environment stable across updates.
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
}
