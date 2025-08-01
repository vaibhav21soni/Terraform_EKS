# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id[local.vpc_key]
}

output "subnet_ids" {
  description = "IDs of all subnets"
  value       = module.vpc.subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value = [
    for key, subnet in local.subnets : module.vpc.subnet_ids[key]
    if !subnet.public
  ]
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value = [
    for key, subnet in local.subnets : module.vpc.subnet_ids[key]
    if subnet.public
  ]
}

output "security_group_ids" {
  description = "IDs of security groups"
  value       = module.vpc.security_group_id
}

output "nat_gateway_ids" {
  description = "IDs of NAT Gateways"
  value       = module.vpc.nat_gateway_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id[local.vpc_key]
}

# EKS Cluster Outputs
output "cluster_id" {
  description = "Name/ID of the EKS cluster"
  value       = module.eks-cluster.eks_clusters["main"].id
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks-cluster.eks_clusters["main"].name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks-cluster.eks_clusters["main"].arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks-cluster.eks_clusters["main"].endpoint
}

output "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  value       = module.eks-cluster.eks_clusters["main"].version
}

output "cluster_platform_version" {
  description = "Platform version for the EKS cluster"
  value       = module.eks-cluster.eks_clusters["main"].platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = module.eks-cluster.eks_clusters["main"].status
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks-cluster.eks_clusters["main"].certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks-cluster.eks_clusters["main"].cluster_security_group_id
}

# OIDC Provider Outputs
output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for the EKS cluster"
  value       = try(module.eks-cluster.eks_oidc_providers["main"].arn, null)
}

# IAM Role Outputs
output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.iam_role.output_iam_role_arns["eks_cluster_role"]
}

output "node_group_iam_role_arn" {
  description = "IAM role ARN of the EKS node group"
  value       = module.iam_role.output_iam_role_arns["eks_node_role"]
}

# Node Group Outputs
output "node_groups" {
  description = "EKS node groups"
  value       = try(module.node_group.eks_node_groups, {})
  sensitive   = false
}

# EKS Add-ons Outputs
output "cluster_addons" {
  description = "Map of attribute maps for all EKS cluster addons enabled"
  value       = try(module.eks-cluster.eks_addons, {})
}

# Workspace and Environment Outputs
output "workspace" {
  description = "Current Terraform workspace"
  value       = terraform.workspace
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

# kubectl Configuration Command
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks-cluster.eks_clusters["main"].name}"
}