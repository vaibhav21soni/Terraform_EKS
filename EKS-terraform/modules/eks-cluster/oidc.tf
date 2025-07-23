

# OIDC Provider Resource
resource "aws_iam_openid_connect_provider" "eks_cluster_oidc" {
  for_each = var.eks_oidc_providers

  client_id_list = each.value.client_id_list

  thumbprint_list = each.value.thumbprint_list != null ? each.value.thumbprint_list : [data.tls_certificate.eks_cluster[each.key].certificates[0].sha1_fingerprint]

  url = each.value.eks_cluster_reference != null ? each.value.eks_cluster_reference : data.aws_eks_cluster.cluster_info[each.key].identity[0].oidc[0].issuer

  tags = merge(
    each.value.tags,
    {
      Name        = "${each.value.cluster_name}-oidc-provider"
      Type        = "EKS-OIDC-Provider"
      ClusterName = each.value.cluster_name
    }
  )
}

# Example terraform.tfvars configuration
/*
eks_oidc_providers = {
  "production-cluster-oidc" = {
    cluster_name = "production-eks"
    tags = {
      Environment = "production"
      Team        = "platform"
    }
  }
  
  "staging-cluster-oidc" = {
    cluster_name   = "staging-eks"
    client_id_list = ["sts.amazonaws.com", "custom-client-id"]
    tags = {
      Environment = "staging"
      Team        = "development"
    }
  }
  
  "existing-cluster-oidc" = {
    cluster_name = "existing-cluster"
    # Reference to existing cluster resource
    eks_cluster_reference = "aws_eks_cluster.clusters['production-cluster'].identity[0].oidc[0].issuer"
    tags = {
      Environment = "production"
      Source      = "existing-resource"
    }
  }
}
*/


# Example IAM role for service account using the OIDC provider

# resource "aws_iam_role" "service_account_role" {
#   for_each = var.eks_oidc_providers

#   name = "${each.value.cluster_name}-service-account-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Effect = "Allow"
#         Condition = {
#           StringEquals = {
#             "${replace(aws_iam_openid_connect_provider.eks_cluster_oidc[each.key].url, "https://", "")}:sub" = "system:serviceaccount:default:my-service-account"
#             "${replace(aws_iam_openid_connect_provider.eks_cluster_oidc[each.key].url, "https://", "")}:aud" = "sts.amazonaws.com"
#           }
#         }
#         Principal = {
#           Federated = aws_iam_openid_connect_provider.eks_cluster_oidc[each.key].arn
#         }
#       }
#     ]
#   })

#   tags = each.value.tags
# }

