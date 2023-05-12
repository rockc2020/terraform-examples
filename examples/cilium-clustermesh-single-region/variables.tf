variable "aws_profile" {
  type        = string
  description = "Name of the AWS profile to use when creatig the resources"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "clusters" {
  type = map(object({
    cidr = string
    eks_users = map(list(string))
    cilium_enabled = bool
  }))
  description = "Map of cluster names to cluster objects"
}
