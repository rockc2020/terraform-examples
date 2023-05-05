variable "aws_profile" {
  type        = string
  description = "Name of the AWS profile to use when creatig the resources."
}

variable "aws_region" {
  type        = string
  description = "AWS region."
}

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

variable "cilium_enabled" {
  default     = false
  type        = bool
  description = "If Cilium is enabled"
}
