# Secure VPC Foundation on AWS — Phase 1

## Purpose
Provide a minimal, production-oriented VPC baseline using cost-effective AWS components:
- Bastion host for controlled SSH access.
- NAT instance for private egress (Free Tier friendly).
- S3 Gateway Endpoint for private access to S3.
- VPC Flow Logs for visibility.

## Architecture
- VPC (10.0.0.0/16)
- Public subnet: bastion (EIP), NAT instance
- Private subnet: application EC2
- Internet Gateway for public egress
- Route tables:
  - Public RT: default → IGW
  - Private RT: default → NAT instance ENI; S3 prefix → Gateway Endpoint
- Flow Logs → S3

See `diagrams/architecture.mmd`.

## Prerequisites
- AWS account with permissions.
- Terraform ≥ 1.6.
- AWS CLI configured (for optional tests).

## Usage
```bash
cd iac/terraform
terraform init
terraform validate
terraform plan
# terraform apply
# terraform destroy
```
Verification

SSH to bastion from admin CIDR.

SSH from bastion to private EC2.

curl -I https://example.com from private EC2 → verifies NAT.

aws s3 ls from private EC2 → verifies Gateway Endpoint.

Confirm Flow Logs appear in S3.


Design Notes

<!-- Key design decisions explained -->NAT instance reduces cost vs NAT Gateway.

Bastion ingress restricted to admin IP only.

Gateway Endpoint improves security and reduces NAT traffic.

Flow Logs stored in S3 for offline analysis.


Repository Structure

secure-vpc-foundation/
├─ diagrams/
├─ iac/terraform/
├─ runbooks/
├─ tests/
├─ README.md
└─ LICENSE

Limitations

Single-AZ example (no HA for bastion or NAT).

Simplified IAM and network policies for demonstration.


Next Steps (Phase 2)

Replace NAT instance with managed NAT Gateway (per AZ).

Add CI/CD for Terraform validation and policy scans.

Integrate monitoring (CloudWatch dashboards/alerts).

Extend to multi-VPC setup (peering or Transit Gateway).
