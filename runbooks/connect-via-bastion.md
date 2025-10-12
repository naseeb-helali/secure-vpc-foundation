<!--
Rationale:
- Explains how to securely connect to private EC2 instances via bastion.
- Keeps private instances unreachable from the internet.
-->
# Runbook: Connect via Bastion Host

## Purpose
Secure administrative access to private EC2 instances via a bastion host.

## Prerequisites
<!-- SSH key and bastion IP are required for connection -->
- SSH key pair available locally.
- Bastion public IP (Terraform output).
- Security Group on bastion limited to your IP/CIDR.

## Steps
1) Connect to bastion from local machine:
```bash
ssh -i ~/.ssh/<KEY>.pem ec2-user@<BASTION_PUBLIC_IP>
