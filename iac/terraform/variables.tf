###############################################################
# variables.tf — Input Variables
# Scope: Phase 1 (Free Tier)
# ------------------------------------------------------------
# Defines configurable parameters for this project.
# Each variable includes a description and a default
# suitable for local testing or Free Tier deployments.
###############################################################

##############################
# General Configuration
##############################

variable "project" {
  description = "Base project name prefix used in all resource names and tags."
  type        = string
  default     = "secure-vpc-foundation"
}

variable "region" {
  description = "AWS region where resources will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "az" {
  description = "Availability Zone for subnet creation."
  type        = string
  default     = "us-east-1a"
}

variable "environment" {
  description = "Deployment environment label (e.g., dev, test, prod)."
  type        = string
  default     = "dev"
}

##############################
# Networking
##############################

variable "vpc_cidr" {
  description = "CIDR block for the main VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_cidr" {
  description = "CIDR block for the public subnet (Bastion and NAT)."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_cidr" {
  description = "CIDR block for the private subnet (internal EC2)."
  type        = string
  default     = "10.0.2.0/24"
}

##############################
# Compute
##############################

variable "instance_type" {
  description = "EC2 instance type used for all instances (Free Tier eligible)."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access."
  type        = string
  default     = "my-keypair"
}

##############################
# Security
##############################

variable "admin_cidr" {
  description = "CIDR block (usually your public IP/32) allowed to SSH into the Bastion."
  type        = string
  default     = "0.0.0.0/0" # change to your IP before production use
}

##############################
# IAM / S3 / Flow Logs
##############################

variable "enable_flow_logs" {
  description = "Whether to enable VPC Flow Logs (true/false)."
  type        = bool
  default     = true
}

variable "flowlogs_traffic_type" {
  description = "Traffic type captured by Flow Logs (ACCEPT, REJECT, or ALL)."
  type        = string
  default     = "ALL"
}

##############################
# Misc
##############################

variable "tags" {
  description = "Additional custom tags to merge with default common tags."
  type        = map(string)
  default     = {}
}
