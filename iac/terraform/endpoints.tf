###############################################################
# endpoint.tf — VPC Gateway Endpoint for S3
# Scope: Phase 1 (Free Tier, single VPC)
# ------------------------------------------------------------
# This file defines:
# - VPC Gateway Endpoint for S3
# - Proper attachment to the private route table
###############################################################

##############################
# S3 Gateway Endpoint
##############################
# Enables private EC2 instances to access S3 services
# directly through AWS internal network (no NAT, no internet).

resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  # Attach to private route table so private subnets can use it.
  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name = "${var.project}-s3-gateway-endpoint"
    Service = "S3"
    Type = "Gateway"
  }
}

##############################
# (Optional) Interface Endpoint Template
##############################
# The section below is commented for future expansion.
# It shows how to add private connectivity to services like
# EC2, CloudWatch, or Secrets Manager.
# Uncomment and customize when needed in Phase 2.

# resource "aws_vpc_endpoint" "ec2_interface" {
#   vpc_id              = aws_vpc.main.id
#   service_name        = "com.amazonaws.${var.region}.ec2"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = [aws_subnet.private.id]
#   security_group_ids  = [aws_security_group.private_ec2_sg.id]
# 
#   private_dns_enabled = true
# 
#   tags = {
#     Name    = "${var.project}-ec2-interface-endpoint"
#     Service = "EC2"
#     Type    = "Interface"
#   }
# }

###############################################################
# Notes:
# - Gateway Endpoints are free and ideal for S3/DynamoDB.
# - Interface Endpoints incur hourly cost; defer to Phase 2.
###############################################################
