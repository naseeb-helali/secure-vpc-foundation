<!--
Purpose:
- This runbook documents the correct and secure method to connect
  to private EC2 instances using a Bastion Host inside the VPC.
- All commands are verified for Amazon Linux 2.
-->

# Runbook: Connect via Bastion Host

## Purpose
Securely access private EC2 instances that do not have public IPs, by routing SSH connections through a bastion host in the public subnet.

---

## Prerequisites
<!-- Make sure the prerequisites below match your deployed environment -->
- Valid SSH key pair downloaded locally (`.pem` file).
- Bastion host public IP (from Terraform outputs).
- Security Group on bastion allows SSH only from your IP/CIDR.
- Security Group on private EC2 allows SSH only from the bastion’s SG.

---

## Steps

### 1. Connect to Bastion Host
From your local terminal:
```bash
ssh -i ~/.ssh/<KEY>.pem ec2-user@<BASTION_PUBLIC_IP>
```



<!--
> Replace <KEY>.pem with your SSH key filename and <BASTION_PUBLIC_IP> with the public IP from Terraform output.

# Connect from Bastion to Private Instance: 
Once logged into the bastion, connect to the private instance:

ssh ec2-user@<PRIVATE_INSTANCE_IP>

# (Optional) Enable SSH Agent Forwarding: 
To avoid copying private keys into the bastion host, use agent forwarding:

ssh -A -i ~/.ssh/<KEY>.pem ec2-user@<BASTION_PUBLIC_IP>
ssh ec2-user@<PRIVATE_INSTANCE_IP>

# Security Notes: 
Disable password authentication on the bastion; allow key-based SSH only.

Restrict bastion inbound SSH to specific admin IPs (your home/office CIDR).

Ensure private EC2 instances have no public IPs.

Regularly rotate SSH keys and audit connection logs.

# Troubleshooting: 
Issue	Possible Cause	Resolution

Permission denied (publickey)	Wrong key or missing permissions	chmod 400 ~/.ssh/<KEY>.pem and re-try
Timeout on private EC2 SSH	Security group rule missing	Allow inbound SSH from bastion SG
Bastion unreachable	Wrong public IP or SG rule	Check Terraform outputs and AWS console
“Agent refused operation”	SSH agent not running locally	Start SSH agent: eval "$(ssh-agent -s)" and add key

# Verification: 
From the private EC2, confirm outbound access works:

curl -I https://example.com
Verify that no direct public SSH access to the private instance is possible.

Notes: 
This is a minimal, Free-Tier-friendly configuration using a bastion host instead of Session Manager.
In Phase 2 (DevOps), consider migrating to AWS SSM Session Manager for fully keyless, auditable access.
---
-->
