output "eks_oidc_providers" {
  description = "EKS OIDC provider information"
  value = {
    for provider_key, oidc in aws_iam_openid_connect_provider.eks_cluster_oidc : provider_key => {
      arn             = oidc.arn
      url             = oidc.url
      thumbprint_list = oidc.thumbprint_list
      client_id_list  = oidc.client_id_list
      tags_all        = oidc.tags_all
    }
  }
}

output "eks_oidc_provider_arns" {
  description = "EKS OIDC provider ARNs"
  value = {
    for provider_key, oidc in aws_iam_openid_connect_provider.eks_cluster_oidc : provider_key => oidc.arn
  }
}

output "eks_oidc_issuer_urls" {
  description = "EKS OIDC issuer URLs"
  value = {
    for provider_key, oidc in aws_iam_openid_connect_provider.eks_cluster_oidc :
    provider_key => oidc.url
  }
}
#OIDC ARN
# In modules/eks-cluster/output.tf
output "output_oidc_provider_arn" {
  value = {
    for k, v in aws_iam_openid_connect_provider.eks_cluster_oidc : k => v.arn
  }
}

output "output_oidc_provider_url" {
  value = {
    for k, v in aws_iam_openid_connect_provider.eks_cluster_oidc : k => v.url
  }
}

output "eks_clusters" {
  description = "EKS cluster information"
  value = {
    for cluster_key, cluster in aws_eks_cluster.clusters : cluster_key => {
      id                        = cluster.id
      arn                       = cluster.arn
      name                      = cluster.name
      endpoint                  = cluster.endpoint
      version                   = cluster.version
      platform_version          = cluster.platform_version
      status                    = cluster.status
      certificate_authority     = cluster.certificate_authority
      cluster_security_group_id = cluster.vpc_config[0].cluster_security_group_id
      vpc_id                    = cluster.vpc_config[0].vpc_id
      service_ipv6_cidr         = try(cluster.kubernetes_network_config[0].service_ipv6_cidr, null)
      tags_all                  = cluster.tags_all
    }
  }
}

output "eks_cluster_endpoints" {
  description = "EKS cluster endpoints"
  value = {
    for cluster_key, cluster in aws_eks_cluster.clusters : cluster_key => cluster.endpoint
  }
}

output "eks_cluster_security_groups" {
  description = "EKS cluster security group IDs"
  value = {
    for cluster_key, cluster in aws_eks_cluster.clusters : cluster_key => cluster.vpc_config[0].cluster_security_group_id
  }
}