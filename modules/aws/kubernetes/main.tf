locals {
  cilium_taint_key = "ignore-taint.cluster-autoscaler.kubernetes.io/cilium-agent-not-ready"
}

terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.75.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.12.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7.1"
    }
  }
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
