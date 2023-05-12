locals {
  cluster1 = "cluster1"
  cluster2 = "cluster2"
}

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

module "cluster1" {
  source = "./modules/cluster"

  name = local.cluster1
  cidr = var.clusters[local.cluster1].cidr
  eks_users = var.clusters[local.cluster1].eks_users
  cilium_enabled = var.clusters[local.cluster1].cilium_enabled
  eks_worker_access_cidrs = [var.clusters[local.cluster2].cidr]
}

module "cluster2" {
  source = "./modules/cluster"

  name = local.cluster2
  cidr = var.clusters[local.cluster2].cidr
  eks_users = var.clusters[local.cluster2].eks_users
  cilium_enabled = var.clusters[local.cluster2].cilium_enabled
  eks_worker_access_cidrs = [var.clusters[local.cluster1].cidr]
}


module "tgw" {
  source = "../../modules/aws/transit-gateway"

  name = "tgw-cluster1-cluster2"
  description = "Transit Gateway for cluster1 and cluster2"

  vpc_attachments = {
    cluster1 = {
      vpc_id           = module.cluster1.vpc_id
      subnet_ids       = module.cluster1.vpc_private_subnets
      route_table_ids  = concat(module.cluster1.vpc_private_route_table_ids, module.cluster1.vpc_public_route_table_ids)
      destination_cidr = module.cluster2.vpc_cidr_block
    },
    cluster2 = {
      vpc_id           = module.cluster2.vpc_id
      subnet_ids       = module.cluster2.vpc_private_subnets
      route_table_ids  = concat(module.cluster2.vpc_private_route_table_ids, module.cluster2.vpc_public_route_table_ids)
      destination_cidr = module.cluster1.vpc_cidr_block
    }
  }
}
