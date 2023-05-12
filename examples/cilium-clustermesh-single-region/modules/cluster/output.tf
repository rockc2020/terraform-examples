output "vpc_id" {
  value       = module.kubernetes.vpc_id
  description = "VPC ID"
}

output "vpc_private_route_table_ids" {
  value       = module.kubernetes.vpc_private_route_table_ids
  description = "VPC private route table ids"
}

output "vpc_public_route_table_ids" {
  value       = module.kubernetes.vpc_public_route_table_ids
  description = "VPC public route table ids"
}

output "vpc_cidr_block" {
  value       = module.kubernetes.vpc_cidr_block
  description = "VPC CIDR block"
}

output "vpc_private_subnets" {
  value       = module.kubernetes.vpc_private_subnets
  description = "Private VPC Subnet ids"
}
