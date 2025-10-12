<!--
Rationale:
- Ensures private instances can reach the internet via NAT instance.
- Validates S3 access through Gateway Endpoint (no internet exposure).
-->
# Runbook: Verify NAT Instance & S3 Gateway Endpoint

## Purpose
Validate that private instances:
- Egress to the internet via the NAT instance.
- Access S3 through the Gateway Endpoint (no internet path).

## Prerequisites
<!-- NAT and Endpoint must exist before running these checks -->
- Terraform apply completed.
- NAT instance created in the public subnet with source/dest check disabled.
- S3 Gateway Endpoint attached to the private route table.
- Instance profile on private EC2 with S3 read permissions for testing.

## Procedure
1) Confirm default route via NAT instance (on private EC2)
```bash
ip route
```

<!--
Expected:
default points to the NAT instance ENI.
Test internet egress (on private EC2)
curl -I https://example.com

Expected:
HTTP 200/301/302.
Test S3 access via Gateway Endpoint (on private EC2)
aws sts get-caller-identity
aws s3 ls

Expected:
S3 operations succeed without traversing the internet/NAT.

Troubleshooting: 
curl fails → verify NAT instance source_dest_check=false; check private route table default route.

aws s3 ls fails → confirm endpoint is attached to private route table; verify instance IAM policy.

SSH path → ensure access to private EC2 only through bastion.
-->
