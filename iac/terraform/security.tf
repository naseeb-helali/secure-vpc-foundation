###############################################################
# security.tf — Network and IAM Security Components
# Scope: Phase 1 (Free Tier, single VPC)
# ------------------------------------------------------------
# This file defines:
# - Security Groups (bastion, private EC2, NAT)
# - Optional Network ACLs (public/private)
# - IAM role for private EC2 (S3 read-only)
###############################################################

##############################
# Bastion Security Group
##############################
# Allows SSH only from admin CIDR.
# Egress open for outbound management traffic.

resource "aws_security_group" "bastion_sg" {
  name        = "${var.project}-bastion-sg"
  description = "Allow SSH from admin CIDR only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from admin network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-bastion-sg"
  }
}

##############################
# NAT Instance Security Group
##############################
# Allows inbound traffic from private subnet range only.
# Outbound fully open to allow NAT translation.

resource "aws_security_group" "nat_sg" {
  name        = "${var.project}-nat-sg"
  description = "Allow private subnet traffic through NAT"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow from private subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.private_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-nat-sg"
  }
}

##############################
# Private EC2 Security Group
##############################
# Allows SSH only from bastion host.
# Allows outbound internet via NAT instance.

resource "aws_security_group" "private_ec2_sg" {
  name        = "${var.project}-private-ec2-sg"
  description = "Allow SSH from bastion; outbound via NAT"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from Bastion Host"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-private-ec2-sg"
  }
}

##############################
# Network ACLs (optional)
##############################
# Adds stateless control layer for public/private subnets.
# Optional: can be skipped if SGs are sufficient.

resource "aws_network_acl" "public_nacl" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.public.id]

  # Inbound: allow SSH (22) and return traffic
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 110
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  # Outbound: allow all
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.project}-public-nacl"
  }
}

resource "aws_network_acl" "private_nacl" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.private.id]

  # Allow internal traffic within VPC
  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  # Outbound internet via NAT instance
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.project}-private-nacl"
  }
}

##############################
# IAM Role for Private EC2 (S3 ReadOnly)
##############################
# Grants S3 read access to private instance.
# Used only for connectivity validation, not production.

resource "aws_iam_role" "app_role" {
  name = "${var.project}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_s3_readonly" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.project}-app-profile"
  role = aws_iam_role.app_role.name
}
