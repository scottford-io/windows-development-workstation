# Windows Development Workstation
This project provides automation code for building a Windows 2019 Developer Workstation in AWS using [Packer]() and [Terraform]().

### Packer Overview
Packer builds a base ami off of the latest Windows 2019 Server image from the Amazon Marketplace. During the build process, Packer installs the following dev tools:

- Chocolatey
- VSCode
- Go
- Python3
- Google Chrome
- Firefox 
- Git

### Requirements
In order use this code with your own environment you will need the following installed on your workstation:

- Packer 
- Terraform
- AWS Account
- AWS CLI Installed and Configured

## Building Workstation AMI with Packer
By default the packer template builds using the `default` profile from the aws credentials file, and will provision in `us-east-1`, but both of these variables can be overridden.
```
cd packer
packer build win2019-dev-workstation.json
...
...
==> amazon-ebs: Creating snapshot tags
==> amazon-ebs: Terminating the source AWS instance...
==> amazon-ebs: Cleaning up any extra volumes...
==> amazon-ebs: No volumes to clean up, skipping
==> amazon-ebs: Deleting temporary security group...
==> amazon-ebs: Deleting temporary keypair...
Build 'amazon-ebs' finished after 20 minutes 16 seconds.

==> Wait completed after 20 minutes 16 seconds

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
