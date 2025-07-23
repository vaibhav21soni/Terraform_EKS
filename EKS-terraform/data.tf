# Data sources for EKS cluster
data "aws_eks_cluster" "cluster" {
  depends_on = [module.eks-cluster]
  name       = module.eks-cluster.eks_clusters["test"].name
}

data "aws_eks_cluster_auth" "cluster" {
  depends_on = [module.eks-cluster]
  name       = module.eks-cluster.eks_clusters["test"].name
}
