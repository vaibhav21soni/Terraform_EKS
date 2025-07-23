# modules/karpenter-helm/variables.tf
variable "karpenter_configs" {
  description = "Map of Karpenter configurations"
  type = map(object({
    name             = string
    namespace        = string
    chart            = optional(string, "karpenter")
    repository       = optional(string, "oci://public.ecr.aws/karpenter")
    version          = optional(string, "0.37.0")
    create_namespace = optional(bool, true)
    values           = optional(list(string), [])
    additional_sets = optional(list(object({
      name  = string
      value = string
      type  = optional(string, "string")
    })), [])
  }))
  default = {}
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for EKS cluster"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL for EKS cluster"
  type        = string
}

variable "node_instance_profile_name" {
  description = "EC2 instance profile name for Karpenter nodes"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

# modules/karpenter-helm/main.tf
# Create IAM role for Karpenter controller
resource "aws_iam_role" "karpenter_controller_role" {
  for_each = var.karpenter_configs

  name = "${each.value.name}-controller-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${var.oidc_issuer_url}:sub" = "system:serviceaccount:${each.value.namespace}:karpenter"
            "${var.oidc_issuer_url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(
    {
      Name        = "${each.value.name}-controller-role"
      Environment = var.environment
    },
    var.tags
  )
}

# Attach Karpenter controller policy
resource "aws_iam_role_policy" "karpenter_controller_policy" {
  for_each = var.karpenter_configs

  name = "${each.value.name}-controller-policy"
  role = aws_iam_role.karpenter_controller_role[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ec2:DescribeImages",
          "ec2:RunInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateTags",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:DescribeSpotPriceHistory",
          "pricing:GetProducts",
          "eks:DescribeCluster"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:TerminateInstances",
          "ec2:DeleteLaunchTemplate"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "ec2:ResourceTag/karpenter.sh/cluster" = var.cluster_name
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "arn:aws:iam::*:role/${var.node_instance_profile_name}"
      }
    ]
  })
}

# Deploy Karpenter using Helm
resource "helm_release" "karpenter" {
  for_each = var.karpenter_configs

  name             = each.value.name
  namespace        = each.value.namespace
  chart            = each.value.chart
  repository       = each.value.repository
  version          = each.value.version
  create_namespace = each.value.create_namespace

  # Core Karpenter configuration
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller_role[each.key].arn
  }

  set {
    name  = "settings.aws.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.aws.clusterEndpoint"
    value = var.cluster_endpoint
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = var.node_instance_profile_name
  }

  set {
    name  = "settings.aws.interruptionQueueName"
    value = "${var.cluster_name}-karpenter"
  }

  # Dynamic additional sets
  dynamic "set" {
    for_each = each.value.additional_sets
    content {
      name  = set.value.name
      value = set.value.value
      type  = set.value.type
    }
  }

  # Custom values files
  values = each.value.values

  depends_on = [
    aws_iam_role_policy.karpenter_controller_policy
  ]
}

# modules/karpenter-helm/outputs.tf
output "karpenter_releases" {
  description = "Helm release information for Karpenter deployments"
  value = {
    for k, v in helm_release.karpenter : k => {
      name      = v.name
      namespace = v.namespace
      version   = v.version
      status    = v.status
    }
  }
}

output "iam_roles" {
  description = "IAM roles created for Karpenter controllers"
  value = {
    for k, v in aws_iam_role.karpenter_controller_role : k => {
      name = v.name
      arn  = v.arn
    }
  }
}



# =====================================================
# USAGE EXAMPLE - main.tf (in your root module)
# =====================================================

# module "karpenter" {
#   source = "./modules/karpenter-helm"

#   cluster_name                 = "my-eks-cluster"
#   oidc_provider_arn           = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
#   oidc_issuer_url             = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
#   node_instance_profile_name  = "KarpenterInstanceProfile"
#   cluster_endpoint            = data.aws_eks_cluster.cluster.endpoint
#   environment                 = "production"

#   karpenter_configs = {
#     # Default Karpenter installation
#     karpenter = {
#       name      = "karpenter"
#       namespace = "karpenter"
#       version   = "0.37.0"
#       additional_sets = [
#         {
#           name  = "controller.resources.requests.cpu"
#           value = "1"
#         },
#         {
#           name  = "controller.resources.requests.memory"
#           value = "1Gi"
#         }
#       ]
#     }

#     # Additional Karpenter for staging workloads
#     karpenter-staging = {
#       name      = "karpenter-staging"
#       namespace = "karpenter-staging"
#       version   = "0.37.0"
#       additional_sets = [
#         {
#           name  = "controller.env.FEATURE_GATES"
#           value = "Drift=true"
#         },
#         {
#           name  = "controller.replicas"
#           value = "1"
#           type  = "string"
#         }
#       ]
#       values = [
#         file("${path.module}/karpenter-staging-values.yaml")
#       ]
#     }
#   }

#   tags = {
#     Project     = "eks-infrastructure"
#     ManagedBy   = "terraform"
#   }
# }

# # Output the module results
# output "karpenter_deployments" {
#   value = module.karpenter.karpenter_releases
# }

# output "karpenter_iam_roles" {
#   value = module.karpenter.iam_roles
# }
