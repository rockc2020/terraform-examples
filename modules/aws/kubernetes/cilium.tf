locals {
  cilium_namespace = "kube-system"
}

################################################################################
# Helm Release
# Cilium chart for operators and agents
################################################################################
resource "helm_release" "cilium" {
  count = var.cilium_enabled ? 1 : 0

  name       = "cilium"
  namespace  = local.cilium_namespace
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = var.cilium_version

  values = [templatefile("${path.module}/values/cilium.yaml.tpl", {
    cluster_name = var.name
    taint_key    = local.cilium_taint_key
  })]
}
