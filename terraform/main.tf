provider "aws" {
  region = var.region
}

resource "random_id" "instance_id" {
  byte_length = 4
}

////////////////////////////////
// VPC Configuration

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs                = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets     = var.vpc_public_subnets
  private_subnets    = var.vpc_private_subnets
  enable_nat_gateway = var.vpc_enable_nat_gateway
}


////////////////////////////////
// Windows Security Groups

module "windows_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "windows-workstations"
  description = "Security group for windows workstation instances"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH ports"
      cidr_blocks = var.myIp
    },
    {
      from_port   = 5985
      to_port     = 5986
      protocol    = "tcp"
      description = "Winrm ports"
      cidr_blocks = var.myIp
    },
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      description = "Remote Desktop ports"
      cidr_blocks = var.myIp
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
  template = file("${path.module}/templates/win_bootstrap.tpl")

  vars = {
    admin_password = var.windows_admin_password
  }
}

////////////////////////////////
// SSM Instance Role

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "EC2-SSM-PROFILE-${random_id.instance_id.hex}"
  role = aws_iam_role.ssm.name
}

resource "aws_iam_role" "ssm" {
  name                = "EC2-SSM-ROLE-${random_id.instance_id.hex}"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}



////////////////////////////////
// Windows Server Instances

module "windows2022_instances" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "win22-dev-workstation-${random_id.instance_id.hex}"
  ami                         = data.aws_ami.win2022_dev_workstation.id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.ssm_instance_profile.name
  vpc_security_group_ids      = [module.windows_sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  key_name                    = var.aws_key_pair_name
  user_data                   = data.template_file.winrm_user_data.rendered
  associate_public_ip_address = true
  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = var.ec2_tags
}