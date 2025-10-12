<!--
Purpose:
- This checklist is used for manual verification of the Secure VPC Foundation (Phase 1) deployment.
- It validates network, security, connectivity, and observability aspects after Terraform apply.
-->

# Manual Test Checklist — Phase 1

---

## Infrastructure Validation
| Check | Expected Result | Status |
|--------|----------------|--------|
| [ ] VPC created successfully | VPC ID visible in Terraform outputs | |
| [ ] DNS support and hostnames enabled | Instances resolve internal hostnames | |
| [ ] Public and private subnets created | Match CIDR ranges (10.0.1.0/24, 10.0.2.0/24) | |
| [ ] Internet Gateway attached | Public route table includes IGW route | |
| [ ] Route tables associated properly | Public RT ↔ Public Subnet, Private RT ↔ Private Subnet | |

---

## Security Validation
| Check | Expected Result | Status |
|--------|----------------|--------|
| [ ] Bastion SG allows SSH only from admin CIDR | Verified in AWS Console | |
| [ ] Private EC2 SG allows SSH only from Bastion SG | Verified via rule dependency | |
| [ ] No public SSH access to private EC2 | Confirmed through denied external SSH | |
| [ ] NAT instance SG allows inbound only from private subnet | Verified via SG configuration | |
| [ ] IAM instance profile attached to private EC2 | Confirmed in instance details | |

---

## Connectivity Tests
| Check | Expected Result | Status |
|--------|----------------|--------|
| [ ] SSH to Bastion Host works | `ssh ec2-user@<BASTION_PUBLIC_IP>` succeeds | |
| [ ] SSH from Bastion to Private EC2 works | `ssh ec2-user@<PRIVATE_IP>` succeeds | |
| [ ] Private EC2 default route points to NAT ENI | `ip route` output confirms | |
| [ ] Internet access via NAT works | `curl -I https://example.com` returns HTTP 200/301/302 | |
| [ ] S3 access via Gateway Endpoint works | `aws s3 ls` succeeds with NAT stopped | |

---

## Observability Validation
| Check | Expected Result | Status |
|--------|----------------|--------|
| [ ] Flow Logs S3 bucket created | `terraform output flowlogs_bucket` returns valid bucket | |
| [ ] Log delivery verified | `.gz` log files appear in S3 within 5–10 min | |
| [ ] Logs contain ACCEPT and REJECT records | Confirmed via `zcat` or `zgrep` | |
| [ ] IAM role for Flow Logs has correct policy | `s3:PutObject` and `s3:GetBucketLocation` allowed | |

---

## Operations & Cost Control
| Check | Expected Result | Status |
|--------|----------------|--------|
| [ ] Terraform destroy runs cleanly | `terraform destroy -auto-approve` completes without error | |
| [ ] No leftover EC2 instances or buckets | Verified via AWS Console or CLI | |
| [ ] Project tag applied to all resources | `Project=secure-vpc-foundation` visible in AWS Console | |
| [ ] Resource teardown validated | `aws ec2 describe-vpcs` shows none | |

---

## Sign-Off
| Field | Detail |
|--------|--------|
| Engineer | Naseeb Helali |
| Date | YYYY-MM-DD |
| Environment | dev |
| Terraform Version | >= 1.6.0 |
| AWS Region | us-east-1 |

---

## Notes
<!-- Best practices and additional remarks -->
- Use `terraform output` to retrieve required values during validation.  
- Wait at least 2–5 minutes after deployment for Flow Logs to appear.  
- Replace placeholder IPs and IDs with actual Terraform outputs.  
- Keep this checklist updated as Phase 2 adds NAT Gateway, CI/CD, and CloudWatch integrations.
## Observability
- [ ] Flow Logs delivered to S3.
- [ ] Sample logs reviewed (`ACCEPT` / `REJECT`).

## Operations
- [ ] Access to private EC2 only via bastion.
- [ ] `terraform destroy -auto-approve` completes successfully.
