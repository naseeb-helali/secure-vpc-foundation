locals {
  name_prefix = var.project
  common_tags = {
    Project     = var.project
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
