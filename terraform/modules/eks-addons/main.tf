# AWS Load Balancer Controller
# Required for ALB ingress functionality
module "lb_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.0"

  name                                   = "${var.prefix}_eks_lb"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "kubernetes_service_account_v1" "service-account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.lb_role.arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "helm_release" "lb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [
    kubernetes_service_account_v1.service-account
  ]

  set = [
    {
      name  = "region"
      value = var.region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    },
    {
      name  = "image.repository"
      value = "602401143452.dkr.ecr.eu-west-2.amazonaws.com/amazon/aws-load-balancer-controller"
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "clusterName"
      value = var.cluster_name
    }
  ]
}

# Polytomic application IAM role
module "polytomic_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.0"
  name    = "${var.prefix}_iam_eks"

  policies = {
    policy = aws_iam_policy.polytomic.arn
  }

  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["polytomic:polytomic"]
    }
  }
}

resource "aws_iam_policy" "polytomic" {
  name        = "${var.prefix}-polytomic"
  description = "Policy for Polytomic"
  policy      = data.aws_iam_policy_document.polytomic.json
}

data "aws_iam_policy_document" "polytomic" {
  statement {
    actions   = ["s3:*"]
    resources = ["*"]
    effect    = "Allow"
  }
}
