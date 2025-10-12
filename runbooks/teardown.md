```markdown
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
