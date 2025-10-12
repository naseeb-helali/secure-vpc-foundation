<!--
Purpose:
- This runbook ensures complete teardown of all AWS resources
  deployed in the Secure VPC Foundation (Phase 1) project.
- Goal: avoid ongoing AWS costs and confirm a clean environment reset.
-->

# Runbook: Teardown & Cost Control

## Purpose
Safely destroy all infrastructure created by Terraform for this project  
to prevent unnecessary AWS charges and to maintain a clean state for future runs.

---

## Prerequisites
<!-- Confirm these before starting teardown -->
- You are in the correct Terraform working directory.
- All critical logs or data have been backed up (especially Flow Logs).
- AWS credentials are valid and point to the correct account.
- You’ve reviewed the plan to ensure no shared resources are affected.

---

## Step 1 — Review the Destroy Plan
Before executing the teardown, always preview the destruction:
```bash
terraform plan -destroy
