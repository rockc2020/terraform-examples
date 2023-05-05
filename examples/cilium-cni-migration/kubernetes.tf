module "kubernetes" {
  source = "../../modules/aws/kubernetes"

  name = var.name
  cidr = var.cidr
  eks_users = var.eks_users
  cilium_enabled = var.cilium_enabled
}
