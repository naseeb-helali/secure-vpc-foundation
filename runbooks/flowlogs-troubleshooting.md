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
zcat <FILE>.gz | head -20```

<!--
Key fields:
srcaddr, dstaddr, srcport, dstport, protocol
action (ACCEPT|REJECT)
log-status (OK|NODATA|SKIPDATA)
Common Issues
Frequent problems observed in test environments -->No objects → check IAM policy for s3:PutObject; verify correct VPC target.

Only ACCEPT or only REJECT → review SG/NACL rules; generate more traffic.

Empty/old logs → ensure active traffic; wait a few minutes for delivery.

Notes
Keep traffic type ALL for validation.
Apply lifecycle policies to manage S3 cost and retention.
-->
