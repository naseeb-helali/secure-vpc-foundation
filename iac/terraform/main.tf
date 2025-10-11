terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.0" }
  }
}

provider "aws" {
  region = var.region
}

# --- AMIs (Amazon Linux 2) ---
data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name" values = ["amzn2-ami-hvm-*-x86_64-gp2"] }
}

# --------- VPC ----------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.project}-vpc" }
}

# --------- Subnets ----------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_cidr
  map_public_ip_on_launch = true
  tags = { Name = "${var.project}-public" }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_cidr
  tags = { Name = "${var.project}-private" }
}

# --------- Internet Gateway & Public RT ----------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "${var.project}-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.project}-rt-public" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --------- NAT Instance (بديل NAT GW لتقليل التكلفة) ----------
resource "aws_instance" "nat" {
  ami                         = coalesce(var.nat_ami, data.aws_ami.al2.id)
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true

  # مهم جدًا ليعمل كـ NAT:
  source_dest_check = false

  user_data = <<-EOF
    #!/bin/bash
    set -eux
    sysctl -w net.ipv4.ip_forward=1
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  EOF

  tags = { Name = "${var.project}-nat-instance" }
}

# --------- Bastion Host ----------
resource "aws_security_group" "bastion_sg" {
  name        = "${var.project}-bastion-sg"
  description = "Allow SSH only from admin IP/CIDR"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr] # عدّلها لاحقًا بعنوانك العام
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-bastion-sg" }
}

resource "aws_instance" "bastion" {
  ami                         = coalesce(var.bastion_ami, data.aws_ami.al2.id)
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  tags = { Name = "${var.project}-bastion" }
}

# --------- Private RT (الافتراضي عبر NAT Instance ENI) ----------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # التوجيه الافتراضي للخارج عبر واجهة NAT Instance
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat.primary_network_interface_id
  }

  tags = { Name = "${var.project}-rt-private" }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# --------- EC2 خاصة (اختبار/تجربة) ----------
resource "aws_security_group" "private_ec2_sg" {
  name   = "${var.project}-private-ec2-sg"
  vpc_id = aws_vpc.main.id

  # SSH مسموح فقط من الباستيون داخل الـVPC
  ingress {
    description                  = "SSH from Bastion SG"
    from_port                    = 22
    to_port                      = 22
    protocol                     = "tcp"
    security_groups              = [aws_security_group.bastion_sg.id]
  }

  # خروج عام للإنترنت (يمر عبر NAT)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-private-ec2-sg" }
}

resource "aws_instance" "app_private" {
  ami           = coalesce(var.app_ami, data.aws_ami.al2.id)
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]
  tags = { Name = "${var.project}-app-private" }
}

# --------- S3 Gateway Endpoint (يوجّه عبر RT الخاصة) ----------
resource "aws_vpc_endpoint" "s3_gw" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.private.id]
  tags = { Name = "${var.project}-s3-gateway-endpoint" }
}

# --------- VPC Flow Logs إلى S3 ----------
resource "random_id" "suffix" {
  byte_length = 2
}

resource "aws_s3_bucket" "flowlogs" {
  bucket = "${var.project}-flowlogs-${random_id.suffix.hex}"
  force_destroy = true
  tags = { Name = "${var.project}-flowlogs" }
}

data "aws_iam_policy_document" "fl_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service" identifiers = ["vpc-flow-logs.amazonaws.com"] }
  }
}

resource "aws_iam_role" "flowlogs_role" {
  name               = "${var.project}-flowlogs-role"
  assume_role_policy = data.aws_iam_policy_document.fl_assume.json
}

data "aws_iam_policy_document" "fl_policy" {
  statement {
    actions   = ["s3:PutObject","s3:PutObjectAcl","s3:GetBucketLocation"]
    resources = [aws_s3_bucket.flowlogs.arn, "${aws_s3_bucket.flowlogs.arn}/*"]
  }
}

resource "aws_iam_role_policy" "flowlogs_policy" {
  name   = "${var.project}-flowlogs-policy"
  role   = aws_iam_role.flowlogs_role.id
  policy = data.aws_iam_policy_document.fl_policy.json
}

resource "aws_flow_log" "vpc" {
  vpc_id               = aws_vpc.main.id
  traffic_type         = "ALL"
  log_destination_type = "s3"
  log_destination      = aws_s3_bucket.flowlogs.arn
  iam_role_arn         = aws_iam_role.flowlogs_role.arn
  tags = { Name = "${var.project}-vpc-flowlogs" }
}
