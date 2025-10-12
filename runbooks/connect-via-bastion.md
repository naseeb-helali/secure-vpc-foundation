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
