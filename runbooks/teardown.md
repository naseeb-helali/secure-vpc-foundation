<!--
Rationale:
- Ensures all test resources are removed to prevent costs.
-->
# Runbook: Teardown & Cost Control

## Purpose
Remove all resources after testing to avoid costs.

## Procedure
```bash
cd iac/terraform
terraform destroy -auto-approve
```
<!--
Post-Checks
No running EC2 instances.
Flow Logs bucket deleted (force_destroy=true).
VPC and subnets no longer listed in the AWS console.

Notes: 
Run terraform plan -destroy before actual teardown if you need to review.
Backup logs before destruction if required.
-->
