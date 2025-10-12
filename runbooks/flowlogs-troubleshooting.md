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
```bash
aws s3 ls s3://<FLOWLOGS_BUCKET> --recursive --human-readable --summarize
Only ACCEPT or only REJECT → review SG/NACL rules; generate more traffic.
Empty/old logs → ensure active traffic; wait a few minutes for delivery.

Notes: 
Keep traffic type ALL for validation.
Apply lifecycle policies to manage S3 cost and retention.-->
