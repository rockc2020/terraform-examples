locals {
  node_security_group_rules = merge({ for cidr in [var.cidr] : cidr => {
    description = "Allow private K8S ingress from custom CIDR source."
    type        = "ingress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [cidr]
    } },
    { for cidr in var.eks_worker_access_cidrs : cidr => {
      description = "Allow private K8S ingress from custom CIDR source."
      type        = "ingress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [cidr]
    } },
    {
      ingress_self_all = {
        description = "Node to node for all ports/protocols"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "ingress"
        self        = true
      }
      ingress_cluster_all = {
        description                   = "Cluster to node for all ports/protocols"
        protocol                      = "-1"
        from_port                     = 0
        to_port                       = 0
        type                          = "ingress"
        source_cluster_security_group = true
      }
      egress_all = {
        description = "Node egress all"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "egress"
        cidr_blocks = ["0.0.0.0/0"]
      }
  })
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  cluster_name    = var.name
  cluster_version = var.eks_cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  enable_irsa     = true

  iam_role_name                      = var.name
  cluster_security_group_name        = var.name
  cluster_security_group_description = "EKS cluster security group."

  node_security_group_name        = var.name
  node_security_group_description = "Security group for all nodes in the cluster."
  node_security_group_tags        = {
    "Name" = "${var.name}-eks_worker_security_group"
  }

  manage_aws_auth_configmap = true
  create_aws_auth_configmap = true
  aws_auth_users            = [for user, groups in var.eks_users : {
    userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${user}"
    username = user
    groups   = groups
  }]

  cluster_security_group_additional_rules = merge({ for cidr in [var.cidr] : cidr => {
    description = "Allow private K8S API ingress from the VPC CIDR."
    type        = "ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [cidr]
    } },
    {
      egress_nodes_ephemeral_ports_tcp = {
        description                = "To nodes 1025-65535"
        protocol                   = "tcp"
        from_port                  = 1025
        to_port                    = 65535
        type                       = "egress"
        source_node_security_group = true
      }
  })

  node_security_group_additional_rules = local.node_security_group_rules

  self_managed_node_group_defaults = {
    security_group_rules = local.node_security_group_rules

    autoscaling_group_tags = {
      "k8s.io/cluster-autoscaler/enabled" : true,
      "k8s.io/cluster-autoscaler/${var.name}" : true,
    }

    update_launch_template_default_version = true

    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]
  }

  self_managed_node_groups = {
    one = {
      instance_type      = "t4g.small"
      ami_id             = "ami-0874ad172603d885c" # https://docs.aws.amazon.com/eks/latest/userguide/retrieve-ami-id.html
      name               = "${var.name}"
      max_size           = 10
      desired_size       = 1
      bootstrap_extra_args = "--kubelet-extra-args '${join(" ", concat(
        # ["--max-pods=12"],
        var.cilium_enabled ? ["--register-with-taints ${local.cilium_taint_key}=true:NoExecute"] : []
      ))}'"
    }
  }

  cluster_addons = {
      coredns = {
        resolve_conflicts = "OVERWRITE"
      }
      kube-proxy = {
        resolve_conflicts = "OVERWRITE"
      }
      vpc-cni = {
        resolve_conflicts = "OVERWRITE"
      }
  }
}

################################################################################
# EKS Cluster Info
# Information about the cluster for output
################################################################################
data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

################################################################################
# EKS Auth Info
# Information about the cluster for output
################################################################################
data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}
