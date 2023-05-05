locals {
  autoscaler_namespace       = "kube-system"
  autoscaler_service_account = "cluster-autoscaler"
}


################################################################################
# IAM Policy Document
################################################################################
data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.eks.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }

  depends_on = [
    module.eks
  ]
}

################################################################################
# IAM Policy
################################################################################
resource "aws_iam_policy" "cluster_autoscaler" {
  name_prefix = "cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for cluster ${var.name}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json

  depends_on = [
    data.aws_iam_policy_document.cluster_autoscaler
  ]
}

################################################################################
# IAM Role
################################################################################
module "iam_assumable_role_cluster_autoscaler" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.2.0"
  create_role                   = true
  role_name                     = "${var.name}-cluster-autoscaler"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.autoscaler_namespace}:${local.autoscaler_service_account}"]

  depends_on = [
    aws_iam_policy.cluster_autoscaler
  ]
}

################################################################################
# Helm Release
# Cluster Autoscaler chart
################################################################################
resource "helm_release" "autoscaler" {
  name       = "aws-cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.19.4"
  namespace  = local.autoscaler_namespace

  values = [templatefile("${path.module}/values/autoscaler.yaml.tpl", {
    awsRegion             = data.aws_region.current.name
    clusterName           = var.name
    serviceAccountName    = local.autoscaler_service_account
    serviceAccountRoleArn = module.iam_assumable_role_cluster_autoscaler.iam_role_arn
  })]

  depends_on = [
    module.iam_assumable_role_cluster_autoscaler
  ]
}
