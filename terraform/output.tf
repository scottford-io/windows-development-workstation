output "winserver2019_public_ips" {
  description = "Public IP addresses of EC2 instances"
  value       = module.windows2019_instances.public_ip
}