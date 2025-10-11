# NAT instance (cost-friendly alternative to NAT Gateway)
resource "aws_instance" "nat" {
  ami                         = coalesce(var.nat_ami, data.aws_ami.al2.id)
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  key_name                    = var.key_name

  # Critical for NAT behavior
  source_dest_check = false

  # Enable IP forwarding and SNAT
  user_data = <<-EOF
    #!/bin/bash
    set -eux
    sysctl -w net.ipv4.ip_forward=1
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  EOF

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-nat-instance" })
}

# Default route from private to NAT instance ENI
resource "aws_route" "private_default_via_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id
}

# Bastion host with SSH hardening
resource "aws_instance" "bastion" {
  ami                         = coalesce(var.bastion_ami, data.aws_ami.al2.id)
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

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
