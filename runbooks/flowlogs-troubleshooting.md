<!--
Purpose:
- This runbook describes how to verify and troubleshoot VPC Flow Logs.
- Focus: S3 delivery validation and record-level inspection.
- Applies to the Secure VPC Foundation (Phase 1) project.
-->

# Runbook: VPC Flow Logs Troubleshooting

## Purpose
Verify that **VPC Flow Logs** are being delivered correctly to the designated S3 bucket  
and help diagnose missing or unexpected records.

---

## Prerequisites
<!-- Ensure the following before starting -->
- Terraform apply has completed successfully.
- S3 bucket for Flow Logs was created (see Terraform output).
- IAM role for Flow Logs has S3 write permissions.
- VPC Flow Logs resource exists and points to the correct VPC.

---
## Step 1 — Verify S3 Delivery
List recent objects in the S3 Flow Logs bucket:
bash
aws s3 ls s3://<FLOWLOGS_BUCKET> --recursive --human-readable --summarize

Expected result: .gz log files appear within a few minutes of VPC activity.

If no objects appear:

Check IAM role policy for missing s3:PutObject.

Verify Flow Logs target VPC ID matches your environment.

Ensure some traffic exists (Flow Logs are event-driven).



---

## Step 2 — Inspect a Sample Log File

Download and read a recent log object:
bash
aws s3 cp s3://<FLOWLOGS_BUCKET>/<PATH>/<FILE>.gz .
zcat <FILE>.gz | head -20

Typical record fields:

version account-id interface-id srcaddr dstaddr srcport dstport protocol packets bytes action log-status

Key fields to check:

Field	Description

srcaddr / dstaddr	Source and destination IPs
srcport / dstport	Port numbers
protocol	Protocol ID (6=TCP, 17=UDP, etc.)
action	ACCEPT / REJECT
log-status	OK / NODATA / SKIPDATA



---

## Step 3 — Analyze Results

Case 1: No Logs Delivered

Verify the IAM role has s3:PutObject permission.

Confirm VPC ID matches your intended target.

Ensure Flow Logs are enabled for ALL traffic.


Case 2: Only ACCEPT or Only REJECT

Review Security Groups and NACLs.

Generate both allowed and denied traffic to verify visibility.


Case 3: Empty or Old Logs

Ensure recent network activity (ping, SSH, curl).

Wait 2–5 minutes — delivery can be delayed slightly.



---

## Step 4 — Confirm Log Contents

You can filter or search within Flow Logs:

zgrep "REJECT" <FILE>.gz | head

Use this to validate that rejected traffic is being captured.


---

## Best Practices

Always set traffic_type = "ALL" during validation.

Apply S3 Lifecycle Policies to manage storage cost.

Enable Server Access Logging on the Flow Logs bucket for traceability.

Use Athena or CloudWatch Logs Insights in Phase 2 for query-based analysis.



---

## Verification Checklist

Check	Expected Result

S3 bucket contains recent log objects. 
Logs show both ACCEPT and REJECT actions. 
IAM role permissions verified. 
Traffic confirmed through NAT / Bastion paths. 



---

## Notes

Flow Logs delivery delay is normal (2–5 minutes).

Use multiple traffic types (HTTP, SSH, ICMP) to test.

Flow Logs are an essential part of your network observability foundation.
