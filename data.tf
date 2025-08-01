# Data sources for EKS cluster
data "aws_eks_cluster" "cluster" {
  depends_on = [module.eks-cluster]
  name       = module.eks-cluster.eks_clusters["main"].name
}

data "aws_eks_cluster_auth" "cluster" {
  depends_on = [module.eks-cluster]
  name       = module.eks-cluster.eks_clusters["main"].name
}

# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# Data source for current AWS region
data "aws_region" "current" {}

# Data source for available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
