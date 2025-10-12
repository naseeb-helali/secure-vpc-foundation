###############################################################
# networking.tf — Core VPC and Subnet Infrastructure
# Scope: Phase 1 (Free Tier, single-region, single-AZ)
# ------------------------------------------------------------
# This file defines:
# - VPC
# - Subnets (public / private)
# - Internet Gateway
# - Route Tables and Associations
###############################################################

##############################
# Virtual Private Cloud (VPC)
##############################
# Creates the main network boundary for all resources.

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-vpc"
    Environment = "dev"
  }
}

##############################
# Subnets
##############################
# Public subnet for Bastion and NAT instance.
# Private subnet for internal EC2s or future application tiers.

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.az

  tags = {
    Name = "${var.project}-public-subnet"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidr
  availability_zone = var.az

  tags = {
    Name = "${var.project}-private-subnet"
    Tier = "private"
  }
}

##############################
# Internet Gateway
##############################
# Enables outbound internet access for public resources.

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-igw"
  }
}

##############################
# Route Tables
##############################
# Public route table — routes 0.0.0.0/0 to IGW.
# Private route table — default route to NAT (added later).

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}-rt-public"
  }
}

# Route table association: public subnet → public RT
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

##############################
# Private Route Table
##############################
# Placeholder route — NAT instance interface added in compute.tf.

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-rt-private"
  }
}

# Associate private subnet to private route table
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
