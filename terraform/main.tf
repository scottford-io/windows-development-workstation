provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

resource "random_id" "instance_id" {
  byte_length = 4
}

////////////////////////////////
// VPC Configuration

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.2"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs                = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  public_subnets     = var.vpc_public_subnets
  enable_nat_gateway = var.vpc_enable_nat_gateway

  tags = var.vpc_tags
}

////////////////////////////////
// Windows Security Groups

module "windows_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.3"

  name        = "cloudplayground-windows-sg"
  description = "Security group for cloudplayground windows instances"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 5985
      to_port     = 5986
      protocol    = "tcp"
      description = "Winrm ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      description = "Remote Desktop ports"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

////////////////////////////////////
// Windows WinRM Bootstrap Template

data "template_file" "winrm_user_data" {
  template = "${file("${path.module}/templates/win_bootstrap.tpl")}"

  vars = {
    admin_password = "${var.windows_admin_password}"
  }
}


////////////////////////////////
// Windows Server Instances

module "windows2019_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.19"

  name                   = "win19-dev-workstation-${random_id.instance_id.hex}"
  instance_count         = var.winserver2019_instance_count
  ami                    = var.workstation_ami
  instance_type          = var.winserver2019_instance_type
  vpc_security_group_ids = [module.vpc.default_security_group_id, module.windows_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  key_name               = var.aws_key_pair_name
  user_data              = data.template_file.winrm_user_data.rendered

  tags = var.ec2_tags
}