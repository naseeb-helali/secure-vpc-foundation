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
bash
terraform plan -destroy

Expected result: The plan lists only resources created by this project (VPC, EC2s, S3 buckets, IAM roles, etc.).

If you see external resources in the list — stop immediately and double-check the workspace.


---

## Step 2 — Destroy the Infrastructure

Run the automated destroy command:

terraform destroy -auto-approve

This removes:

VPC, subnets, and route tables

Internet Gateway and endpoints

Bastion host, NAT instance, and private EC2

IAM roles, security groups, and S3 Flow Logs bucket


> Note: force_destroy = true ensures S3 buckets are deleted even if not empty.




---

## Step 3 — Post-Teardown Validation

Confirm all major resources are gone:

aws ec2 describe-vpcs --filters "Name=tag:Project,Values=secure-vpc-foundation"
aws ec2 describe-instances --filters "Name=tag:Project,Values=secure-vpc-foundation"
aws s3 ls | grep flowlogs

Expected: no VPCs, EC2 instances, or S3 buckets remain for this project.


---

## Step 4 — (Optional) Clean Local State

If you want a fully fresh start:

rm -rf .terraform/ terraform.tfstate terraform.tfstate.backup
terraform init

> This resets your local environment and ensures Terraform re-downloads all modules and providers next time.




---

## Cost-Control Best Practices

Always destroy unused test environments after validation.

Use AWS Budgets to monitor Free-Tier usage.

Keep force_destroy = true for temporary buckets only.

Schedule periodic cleanup of stale resources via tags.

Maintain separate AWS accounts for sandbox vs. production work.



---

## Verification Checklist

Check	Expected Result

All Terraform resources destroyed successfully. 
S3 Flow Logs bucket deleted. 
No running EC2 instances in the region. 
No VPCs or subnets remain for this project. 
Terraform state cleaned up if needed. 



---

## Notes

This runbook is idempotent — running it multiple times has no side effects.

Always keep at least one post-teardown validation step to ensure no AWS costs persist.

In Phase 2, teardown will include CI/CD state locking and remote backend cleanup.
