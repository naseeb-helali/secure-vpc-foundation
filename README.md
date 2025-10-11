# Secure VPC Foundation on AWS

## Overview
This project builds a secure and cost-efficient AWS VPC architecture using Terraform.  
It demonstrates essential network design principles—segmentation, controlled connectivity, and observability—implemented entirely with Free-Tier resources.

The design is based on best practices covered in *AWS* and serves as a foundation layer for future DevOps automation and CI/CD integration.

---

## Architecture Summary

| Component | Purpose |
|------------|----------|
| **VPC (10.0.0.0/16)** | Defines an isolated network boundary. |
| **Public / Private Subnets** | Separate internet-facing and internal workloads. |
| **NAT Instance** | Enables outbound access for private resources without inbound exposure. |
| **Bastion Host** | Provides controlled administrative access via SSH. |
| **S3 Gateway Endpoint** | Allows private S3 access without routing through the internet. |
| **VPC Flow Logs → S3** | Captures and audits network traffic for troubleshooting and security. |

---

## Design Highlights
- Uses **NAT Instance** instead of NAT Gateway to stay within the Free Tier while maintaining outbound routing.  
- Restricts SSH access to a defined admin CIDR (principle of least privilege).  
- Implements **VPC Flow Logs** for visibility and compliance.  
- Provides a clean separation between public administration and private workloads.  

---

## Repository Structure
