<!--
Rationale:
- Used to confirm Flow Logs delivery and analyze dropped/allowed traffic.
-->
# Runbook: VPC Flow Logs Troubleshooting

## Purpose
Confirm delivery of VPC Flow Logs to S3 and diagnose missing records.

## Checks
1) Verify S3 delivery  
   Locate the Flow Logs bucket (Terraform output) and confirm recent `.gz` log objects.

2) Download and inspect a sample
```bash
aws s3 cp s3://<FLOWLOGS_BUCKET>/<PATH>/<FILE>.gz .
zcat <FILE>.gz | head -20
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

<!--
Key fields:

srcaddr, dstaddr, srcport, dstport, protocol

action (ACCEPT|REJECT)

log-status (OK|NODATA|SKIPDATA)


Common Issues

<!-- Frequent problems observed in test environments -->No objects → check IAM policy for s3:PutObject; verify correct VPC target.

Only ACCEPT or only REJECT → review SG/NACL rules; generate more traffic.

Empty/old logs → ensure active traffic; wait a few minutes for delivery.


Notes

Keep traffic type ALL for validation.

Apply lifecycle policies to manage S3 cost and retention.
-->
