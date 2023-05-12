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

module "kubernetes" {
  source = "../../../../modules/aws/kubernetes"

  name = var.name
  cidr = var.cidr
  eks_users = var.eks_users
  eks_worker_access_cidrs = var.eks_worker_access_cidrs
  cilium_enabled = var.cilium_enabled
}

module "echoserver" {
  source = "../../../../modules/apps/ealen-echo-server"

  name = "echoserver"
  namespace = "echoserver"
}
