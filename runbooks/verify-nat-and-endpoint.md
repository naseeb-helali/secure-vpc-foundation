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
bash
ip route

Expected result:
The default route (0.0.0.0/0) should point to the NAT instance’s network interface (ENI ID).
Example output:

default via 10.0.1.10 dev eth0


---

## Step 2 — Test Internet Egress (via NAT Instance)

From the private EC2:

curl -I https://example.com

Expected result:
You receive an HTTP response (200, 301, or 302).

> If the request fails:

Verify that source_dest_check is disabled on the NAT instance.

Check that the private route table’s default route points to the NAT instance ENI.

Confirm NAT instance SG allows outbound traffic (0.0.0.0/0).





---

## Step 3 — Validate S3 Gateway Endpoint Access

Still on the private EC2:

aws sts get-caller-identity
aws s3 ls

Expected result:
The commands succeed — even with the NAT instance stopped (proof that traffic uses the Gateway Endpoint).

> If aws s3 ls fails:

Verify the S3 Gateway Endpoint is attached to the private route table.

Check the instance IAM role has AmazonS3ReadOnlyAccess.

Confirm DNS resolution is enabled in the VPC.





---

## Step 4 — Confirm No Internet Path to S3

To ensure requests are internal, run:

traceroute s3.amazonaws.com

Expected result:
Traffic stays within private IP space (no hops to public internet).

If you see public IP hops, verify that:

S3 endpoint route exists in private route table.

NAT instance is not being used for S3 (Gateway endpoint should bypass it).



---

## Step 5 — Troubleshooting Summary

Symptom	Likely Cause	Resolution

curl fails	NAT instance misconfigured or SG blocked	Disable source_dest_check, verify routes
aws s3 ls fails	Missing endpoint route or IAM permissions	Check S3 endpoint and instance role
S3 requests exit via NAT	Missing endpoint in private route table	Re-attach endpoint to correct route table
Timeout on SSH	Bastion or private SG rule issue	Allow SSH from bastion SG to private EC2 SG



---

## Verification Checklist

Check	Expected Result

Private route table default route → NAT instance ENI. 
curl -I https://example.com from private EC2 succeeds. 
aws s3 ls works with NAT stopped. 
S3 Gateway Endpoint attached to private RT. 
No public internet hops in traceroute to S3.



---

## Notes

Always keep NAT instance small (t3.micro) and stop it when idle to control costs.

In Phase 2, replace NAT instance with NAT Gateway for higher availability.

Keep S3 Gateway Endpoint for cost-efficiency — it’s free and improves security.
