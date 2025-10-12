<!--
Rationale:
- Quick manual validation to confirm core infrastructure functionality.
-->
# Manual Test Checklist — Phase 1

## Infrastructure
- [ ] VPC created with DNS support and hostnames enabled.
- [ ] Public and private subnets created and associated correctly.
- [ ] Internet Gateway attached; public RT default route to IGW.

## Security
- [ ] Bastion SG allows SSH only from admin CIDR.
- [ ] Private EC2 SG allows SSH only from bastion SG.
- [ ] No public SSH access on private EC2.

## Connectivity
- [ ] Private EC2 default route points to NAT instance ENI.
- [ ] `curl -I https://example.com` succeeds from private EC2.
- [ ] S3 Gateway Endpoint attached to private RT.
- [ ] `aws s3 ls` succeeds from private EC2.

## Observability
- [ ] Flow Logs delivered to S3.
- [ ] Sample logs reviewed (`ACCEPT` / `REJECT`).

## Operations
- [ ] Access to private EC2 only via bastion.
- [ ] `terraform destroy -auto-approve` completes successfully.
