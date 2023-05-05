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
