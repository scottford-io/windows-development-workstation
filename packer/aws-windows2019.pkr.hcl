variable "aws_region" {
  type    = string
  default = "us-east-1"
}

data "amazon-ami" "windows2019" {
  filters = {
    name                = "Windows_Server-2019-English-Full-Base-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["801119661308"]
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "windows2019" {
  ami_name      = "windows2019-dev-workstation-${local.timestamp}"
  communicator  = "winrm"
  instance_type = "t2.micro"
  run_tags = {
    Automation    = "packer"
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Version       = local.timestamp
  }
  shutdown_behavior = "terminate"
  source_ami        = data.amazon-ami.windows2019.id
  tags = {
    Automation    = "packer"
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Name          = "win19-dev-workstation-${local.timestamp}"
    OS            = "windows"
    Release       = "2019 Core"
    GitHub        = "github.com/scottford-io/windows-developer-workstation"
  }
  user_data_file = "unattended/bootstrap.txt"
  winrm_timeout  = "15m"
  winrm_username = "Administrator"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.amazon-ebs.windows2019"]

  provisioner "powershell" {
    scripts = [
      "./scripts/disable-uac.ps1",
      "./scripts/choco.ps1"
    ]
  }

  provisioner "powershell" {
    inline = [
      "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\SendWindowsIsReady.ps1 -Schedule", "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\InitializeInstance.ps1 -Schedule", "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\SysprepInstance.ps1 -NoShutdown"
    ]
    only = ["amazon-ebs"]
  }

}
