<!--
Purpose:
- This runbook verifies that the NAT instance provides internet egress for private EC2 instances,
  and that the S3 Gateway Endpoint enables private S3 access without traversing the public internet.
- Scope: Secure VPC Foundation (Phase 1)
-->

# Runbook: Verify NAT Instance & S3 Gateway Endpoint

## Purpose
Validate that:
- Private EC2 instances can access the internet **via NAT instance** (not directly).  
- S3 operations from private EC2 instances are routed **through the Gateway Endpoint**, not over the internet.  

---

## Prerequisites
<!-- Confirm environment readiness before running validation -->
- Terraform apply has completed successfully.  
- NAT instance deployed in the public subnet with `source_dest_check = false`.  
- S3 Gateway Endpoint created and attached to the **private route table**.  
- IAM instance profile with S3 read access attached to the private EC2.  
- Bastion Host available for SSH jump access.  

---

## Step 1 — Confirm Private Route Table Configuration
SSH into the private EC2 (via bastion) and check the routing table:
```bash
ip route```bash
ip route
```

<!--
Expected:
default points to the NAT instance ENI.
Test internet egress (on private EC2)
curl -I https://example.com

Expected:
HTTP 200/301/302.
Test S3 access via Gateway Endpoint (on private EC2)
aws sts get-caller-identity
aws s3 ls

Expected:
S3 operations succeed without traversing the internet/NAT.

Troubleshooting: 
curl fails → verify NAT instance source_dest_check=false; check private route table default route.

aws s3 ls fails → confirm endpoint is attached to private route table; verify instance IAM policy.

SSH path → ensure access to private EC2 only through bastion.
-->
