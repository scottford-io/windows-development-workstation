output "winserver2022_public_ip" {
  description = "Public IP addresses of EC2 instances"
  value       = module.windows2022_instances.public_ip
}