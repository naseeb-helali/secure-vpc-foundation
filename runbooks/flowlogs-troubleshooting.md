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
