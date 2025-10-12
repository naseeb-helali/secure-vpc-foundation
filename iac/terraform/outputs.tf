###############################################################
# outputs.tf — Key Outputs for Secure VPC Foundation
# Scope: Phase 1 (Free Tier)
# ------------------------------------------------------------
# This file defines Terraform outputs that provide visibility
# into deployed infrastructure components.
###############################################################

##############################
# VPC & Subnets
##############################

output "vpc_id" {
  description = "ID of the main VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet (bastion + NAT)"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet (application EC2)"
  value       = aws_subnet.private.id
}

##############################
# Internet Gateway & Route Tables
##############################

output "internet_gateway_id" {
  description = "ID of the Internet Gateway attached to the VPC"
  value       = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  description = "ID of the route table associated with the public subnet"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the route table associated with the private subnet"
  value       = aws_route_table.private.id
}

##############################
# Compute Instances
##############################

output "bastion_public_ip" {
  description = "Public IP of the Bastion Host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP of the Bastion Host"
  value       = aws_instance.bastion.private_ip
}

output "nat_instance_id" {
  description = "ID of the NAT Instance"
  value       = aws_instance.nat.id
}

output "private_instance_private_ip" {
  description = "Private IP of the internal EC2 instance"
  value       = aws_instance.private_app.private_ip
}

##############################
# Security & IAM
##############################

output "bastion_sg_id" {
  description = "Security Group ID for Bastion Host"
  value       = aws_security_group.bastion_sg.id
}

output "private_ec2_sg_id" {
  description = "Security Group ID for private EC2 instance"
  value       = aws_security_group.private_ec2_sg.id
}

output "app_instance_profile" {
  description = "IAM instance profile attached to private EC2"
  value       = aws_iam_instance_profile.app_profile.name
}

##############################
# Networking & Monitoring
##############################

output "s3_gateway_endpoint_id" {
  description = "ID of the S3 Gateway Endpoint for private subnet access"
  value       = aws_vpc_endpoint.s3_gateway.id
}

output "flowlogs_bucket" {
  description = "Name of the S3 bucket storing VPC Flow Logs"
  value       = aws_s3_bucket.flowlogs.bucket
}

output "flowlogs_role_name" {
  description = "IAM role used by Flow Logs service"
  value       = aws_iam_role.flowlogs_role.name
}

##############################
# Miscellaneous
##############################

output "region" {
  description = "AWS region used for deployment"
  value       = var.region
}

output "project_name" {
  description = "Project name prefix applied to resources"
  value       = var.project
}
