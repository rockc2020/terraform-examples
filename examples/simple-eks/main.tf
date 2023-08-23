terraform {
  required_version = ">= 1.3"
  backend "s3" {
    bucket  = var.name
    key     = "${var.name}.tfstate"
    region  = var.aws_region
    profile = var.aws_profile
  }

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

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "kubernetes" {
  host                   = module.kubernetes.eks_endpoint
  cluster_ca_certificate = base64decode(module.kubernetes.eks_certificate)
  token                  = module.kubernetes.eks_token
}

provider "helm" {
  kubernetes {
    host                   = module.kubernetes.eks_endpoint
    cluster_ca_certificate = base64decode(module.kubernetes.eks_certificate)
    token                  = module.kubernetes.eks_token
  }
}
