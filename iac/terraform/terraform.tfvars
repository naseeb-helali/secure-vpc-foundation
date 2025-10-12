###############################################################
# terraform.tfvars — Environment Configuration
# Scope: Phase 1 (Free Tier)
# ------------------------------------------------------------
# Override variable defaults here to customize your deployment.
# Each variable corresponds to those defined in variables.tf.
###############################################################

##############################
# General Settings
##############################

project      = "secure-vpc-foundation"
region       = "us-east-1"
az           = "us-east-1a"
environment  = "dev"

##############################
# Networking
##############################

vpc_cidr      = "10.0.0.0/16"
public_cidr   = "10.0.1.0/24"
private_cidr  = "10.0.2.0/24"

##############################
# Compute
##############################

instance_type = "t3.micro"
key_name      = "my-keypair"      # replace with your actual EC2 key pair name

##############################
# Security
##############################

# IMPORTANT: change this to your own public IP to restrict SSH access
admin_cidr = "203.0.113.25/32"

##############################
# Logging & Monitoring
##############################

enable_flow_logs       = true
flowlogs_traffic_type  = "ALL"

##############################
# Tags
##############################

tags = {
  Owner        = "Naseeb Helali"
  Environment  = "dev"
  Purpose      = "secure-vpc-foundation"
  ManagedBy    = "Terraform"
}
