###############################################################
# compute.tf — EC2 Instances and Compute Layer
# Scope: Phase 1 (Free Tier)
# ------------------------------------------------------------
# This file defines:
# - NAT Instance (public)
# - Bastion Host (public)
# - Private EC2 instance (private)
###############################################################

##############################
# Data Sources
##############################
# Fetch the latest Amazon Linux 2 AMI for x86_64 (Free Tier eligible).

data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

##############################
# NAT Instance
##############################
# Provides outbound internet access for private subnet workloads.
# Source/Dest check must be disabled for NAT behavior.

resource "aws_instance" "nat" {
  ami                         = data.aws_ami.al2.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.nat_sg.id]
  associate_public_ip_address = true

  # Critical: disable source/destination check
  source_dest_check = false

  user_data = <<-EOF
    #!/bin/bash
    set -eux
    # Enable IP forwarding
    sysctl -w net.ipv4.ip_forward=1
    # Configure NAT masquerade rule
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  EOF

  tags = {
    Name = "${var.project}-nat-instance"
    Role = "nat"
  }
}

##############################
# Bastion Host
##############################
# Jump server for secure SSH access into private subnets.

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    set -eux
    # Harden SSH configuration
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    systemctl restart sshd
  EOF

  tags = {
    Name = "${var.project}-bastion-host"
    Role = "bastion"
  }
}

##############################
# Private EC2 Instance
##############################
# Deployed in the private subnet for validation and internal workloads.
# Accessible only via the bastion host.

resource "aws_instance" "private_app" {
  ami                    = data.aws_ami.al2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.app_profile.name
  key_name               = var.key_name

  tags = {
    Name = "${var.project}-private-ec2"
    Role = "app"
  }
}

##############################
# Private Route to NAT Instance
##############################
# Adds a default route in the private route table to the NAT instance ENI.

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id

  depends_on = [aws_instance.nat]
}  key_name                    = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    set -eux
    sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
  EOF

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-bastion" })
}

# IAM role for private EC2 to read S3 (for testing S3 access via Gateway Endpoint)
resource "aws_iam_role" "app_role" {
  name = "${local.name_prefix}-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { "Service" : "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "app_s3_ro" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "${local.name_prefix}-app-profile"
  role = aws_iam_role.app_role.name
}

# Private EC2 (test instance)
resource "aws_instance" "app_private" {
  ami                  = coalesce(var.app_ami, data.aws_ami.al2.id)
  instance_type        = var.instance_type
  subnet_id            = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]
  iam_instance_profile = aws_iam_instance_profile.app_profile.name
  key_name             = var.key_name

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-app-private" })
}
