
```markdown
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
