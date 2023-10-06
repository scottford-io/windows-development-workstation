////////////////////////////////
// AWS Connection

variable "region" {
  default = "us-east-1"
}

variable "aws_key_pair_name" {}

////////////////////////////////
// VPC Settings

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "Windows Development"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_private_subnets" {
  description = "Private subnets for VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_public_subnets" {
  description = "Public subnets for VPC"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT gateway for VPC"
  type        = bool
  default     = true
}

variable "vpc_tags" {
  description = "Tags to apply to resources created by VPC module"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "Windows Development Workstation"
  }
}

variable "myIp" {
  description = "IP address to allow RDP and SSH access to Windows workstation. Example: 24.68.12.145/32"
}
////////////////////////////////
// EC2 Settings

variable "ec2_tags" {
  description = "Tags to apply to resources created by EC2 module"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "windows-development-vpc"
  }
}

variable "instance_type" {
  default = "t2.medium"
}

variable "windows_admin_password" {
  default = "C10udp1@gr0und2023"
}

variable "ami_owner_id" {
  description = "Owner ID for Packer Base Image"
}