variable "name" {
  type        = string
  description = "A name for this module"
}

variable "cidr" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "eks_cluster_version" {
  default     = "1.26"
  type        = string
  description = "The Kubernetes version of the EKS cluster"
}

variable "eks_users" {
  default = {}
  type = map(list(string))
  description = "Additional IAM users for the aws-auth configmap"
}

variable "cilium_enabled" {
  default     = false
  type        = bool
  description = "If Cilium is enabled"
}

variable "cilium_version" {
  default     = "1.13.2"
  type        = string
  description = "The version of Cilium"
}
