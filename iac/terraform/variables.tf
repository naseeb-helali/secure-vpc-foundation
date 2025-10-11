variable "region"        { type = string  default = "us-east-1" }
variable "project"       { type = string  default = "secure-vpc-foundation" }

variable "vpc_cidr"      { type = string  default = "10.0.0.0/16" }
variable "public_cidr"   { type = string  default = "10.0.1.0/24" }
variable "private_cidr"  { type = string  default = "10.0.2.0/24" }

variable "instance_type" { type = string  default = "t3.micro" }

# اختياري: إن تركتها فارغة سنستخدم أحدث Amazon Linux 2 تلقائيًا (data.aws_ami.al2)
variable "nat_ami"      { type = string  default = "" }
variable "bastion_ami"  { type = string  default = "" }
variable "app_ami"      { type = string  default = "" }

# عنوانك/شبكتك للوصول إلى الباستيون (عدّلها!)
variable "admin_cidr"    { type = string  default = "0.0.0.0/0" }
