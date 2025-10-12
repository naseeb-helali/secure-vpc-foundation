###############################################################
# locals.tf — Centralized local variables and tagging
# Scope: Phase 1 (Free Tier)
# ------------------------------------------------------------
# This file defines:
# - Common tag map used across all resources
# - Environment metadata
# - Helpful derived values for naming consistency
###############################################################

##############################
# Project-wide Locals
##############################

locals {
  # Basic project metadata
  project_name = var.project
  environment  = "dev"
  region       = var.region

  # Derived naming patterns for consistent tagging
  name_prefix = "${local.project_name}-${local.environment}"

  # Standard tags applied to all resources
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Owner       = "Naseeb Helali"
  }

  # Convenience locals for subnets (used in other modules/files)
  public_subnet_name  = "${local.name_prefix}-public"
  private_subnet_name = "${local.name_prefix}-private"

  # Example of central AZ selection (optional override via variable)
  az_default = var.az
}
