output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "vpc_private_route_table_ids" {
  value       = module.vpc.private_route_table_ids
  description = "VPC private route table ids"
}

output "vpc_public_route_table_ids" {
  value       = module.vpc.public_route_table_ids
  description = "VPC public route table ids"
}

output "vpc_cidr_block" {
  value       = module.vpc.vpc_cidr_block
  description = "VPC CIDR block"
}

output "vpc_private_subnets" {
  value       = module.vpc.private_subnets
  description = "Private VPC Subnet ids"
}

output "eks_endpoint" {
  value       = data.aws_eks_cluster.eks.endpoint
  description = "The endpoint for the EKS cluster"
}

output "eks_certificate" {
  value       = data.aws_eks_cluster.eks.certificate_authority.0.data
  sensitive   = true
  description = "The TLS certificate for the EKS cluster"
}

output "eks_token" {
  value       = data.aws_eks_cluster_auth.eks.token
  sensitive   = true
  description = "The connection token for the EKS cluster"
}
