output "alb_dns_name" {
  value       = module.web-cluster.alb_dns_name
  description = "URL to access the application"
}

output "vpc_id" {
  value       = module.networking.vpc_id
  description = "VPC ID for this environment"
}
