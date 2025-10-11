variable "region"        { type = string  default = "us-east-1" }
variable "project"       { type = string  default = "secure-vpc-foundation" }

variable "vpc_cidr"      { type = string  default = "10.0.0.0/16" }
variable "public_cidr"   { type = string  default = "10.0.1.0/24" }
variable "private_cidr"  { type = string  default = "10.0.2.0/24" }

variable "instance_type" { type = string  default = "t3.micro" }

# Optional AMI overrides (fallback to Amazon Linux 2 data source)
variable "nat_ami"      { type = string  default = "" }
variable "bastion_ami"  { type = string  default = "" }
variable "app_ami"      { type = string  default = "" }

# SSH
variable "key_name"     { type = string  default = "" }        # optional EC2 key pair name
variable "admin_cidr"   { type = string  default = "0.0.0.0/0" } # replace with YOUR.PUBLIC.IP/32 before apply
