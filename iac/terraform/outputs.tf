output "vpc_id"            { value = aws_vpc.main.id }
output "public_subnet_id"  { value = aws_subnet.public.id }
output "private_subnet_id" { value = aws_subnet.private.id }

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
  description = "Use this IP for SSH to bastion"
}

output "nat_instance_id" {
  value = aws_instance.nat.id
}

output "flowlogs_bucket" {
  value = aws_s3_bucket.flowlogs.bucket
}
