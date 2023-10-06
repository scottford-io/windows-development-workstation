output "winserver2022_public_ip" {
  description = "Public IP addresses of EC2 instances"
  value       = module.windows2022_instances.public_ip
}

output "dev_workstation_ami_id" {
  value = data.aws_ami.win2022_dev_workstation.id
}