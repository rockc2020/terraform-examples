terraform {
  required_version = ">= 0.13"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
    }
  }
}

################################################################################
# Helm Release
# Cilium chart for operators and agents
################################################################################
resource "helm_release" "ealenn_echoserver" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://ealenn.github.io/charts"
  chart      = "echo-server"

  create_namespace = true
}
