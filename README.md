# Windows Development Workstation
This project provides automation code for building a Windows 2019/2022 Developer Workstation in AWS using [Packer](https://www.packer.io/) and [Terraform](https://www.terraform.io/).

## Installed Software
Both Packer templates build the AMI from the latest versions of Windows 2019 and 2022 which are maintained by Amazon on the Amazon Marketplace. During the build process, Packer installs the following dev tools:

- [Chocolatey](https://chocolatey.org/) - Package Manager for Windows
- [openssh](https://community.chocolatey.org/packages/openssh) - Win32 OpenSSH
- [Microsoft Visual Studio Code](https://code.visualstudio.com/) - Open source code editor from Microsoft.
- [GoLang](https://go.dev/) - Go is an open source programming language supported by Google.
- [Python3](https://www.python.org/) - Python 3 programming language.
- [Google Chrome](https://www.google.com/chrome/downloads/) - Google Chrome Web Browser.
- [Firefox](https://www.mozilla.org/en-US/firefox/new/) - Firefox browser.
- [Git](https://git-scm.com/) - Free and open source distributed version control system.

## Requirements
In order use this code with your own environment you will need the following installed on your workstation:

- Packer 
- Terraform
- AWS Account
- AWS CLI Installed and Configured

## Building Workstation AMI with Packer
By default the packer template builds using the `default` profile from the aws credentials file, and will provision in `us-east-1`, but both of these variables can be overridden.
```
cd packer
packer build aws-windows2019.pkr.hcl
amazon-ebs.windows2019: output will be in this color.

==> amazon-ebs.windows2019: Prevalidating any provided VPC information
==> amazon-ebs.windows2019: Prevalidating AMI Name: windows2019-dev-workstation-20220731223804
    amazon-ebs.windows2019: Found Image ID: ami-05912b6333beaa478
==> amazon-ebs.windows2019: Creating temporary keypair: packer_62e7044c-e50e-c9ad-01ea-b2c80060c68e
==> amazon-ebs.windows2019: Creating temporary security group for this instance: packer_62e70452-0b4b-14a5-7b6f-c0f683e8627f
==> amazon-ebs.windows2019: Authorizing access to port 5985 from [0.0.0.0/0] in the temporary security groups...
==> amazon-ebs.windows2019: Launching a source AWS instance...==> Wait completed after 20 minutes 16 seconds

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:
us-east-1: ami-0d4e8c2c7b3abc123
```

At the end of the Packer run you will see the generated `ami-`. Copy that ami id and move on to Terraform.

## Provisioning an instance with Terraform
The Terraform code will create a VPC, Security group, and an instance of the Windows 2019 Dev Workstation. Checkout the `variables.tf` to override configuration using a `terraform.tfvars` file.

```
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

Once complete, Terraform will print out the `public_ip` of the Windows instance and you can RDP to it.
