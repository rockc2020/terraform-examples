variable "name" {
  type        = string
  description = "The name of this module"
}

variable "cidr" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "eks_users" {
  default = {}
  type = map(list(string))
  description = "Additional IAM users to add to the aws-auth configmap"
}

variable "eks_worker_access_cidrs" {
  default     = []
  type        = list(string)
  description = "A list of CIDRs allowed to access the EKS workers"
}

variable "cilium_enabled" {
  default     = false
  type        = bool
  description = "If Cilium is enabled"
}
