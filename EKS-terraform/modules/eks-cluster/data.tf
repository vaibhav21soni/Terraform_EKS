data "aws_eks_cluster_auth" "cluster_auth" {
  for_each = var.eks_clusters
  name     = aws_eks_cluster.clusters[each.key].name
}

# Additional data source for cluster information (optional)
data "aws_eks_cluster" "cluster_name" {
  for_each = var.eks_clusters
  name     = aws_eks_cluster.clusters[each.key].name

  depends_on = [aws_eks_cluster.clusters]
}



# Data source to get TLS certificate from EKS OIDC issuer
data "tls_certificate" "eks_cluster" {
  for_each = var.eks_oidc_providers

  # If using existing cluster resource reference, use that; otherwise use cluster name
  url = each.value.eks_cluster_reference != null ? each.value.eks_cluster_reference : data.aws_eks_cluster.cluster_info[each.key].identity[0].oidc[0].issuer
}

# Data source to get EKS cluster information (when not referencing existing resource)
data "aws_eks_cluster" "cluster_info" {
  for_each = {
    for provider_key, provider in var.eks_oidc_providers : provider_key => provider if provider.eks_cluster_reference == null
  }

  name = each.value.cluster_name != null ? each.value.cluster_name : "default-cluster"
  depends_on = [ aws_eks_cluster.clusters ]
  }