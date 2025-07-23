output "vpc_id" {
  value = module.vpc.vpc_id

}

output "eip_nat_ids" {
  description = "IDs of all allocated Elastic IPs for NAT Gateways"
  value       = module.vpc.eip_nat_ids
}

output "eip_nat_public_ips" {
  description = "Public IPs of Elastic IPs for NAT Gateways"
  value       = module.vpc.eip_nat_public_ips
}

output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "IDs of NAT Gateways"
  value       = module.vpc.nat_gateway_ids
}

output "route_table_ids" {
  description = "IDs of all route tables"
  value       = module.vpc.route_table_ids
}

output "subnet_route_table_association_ids" {
  description = "IDs of route table associations for subnets"
  value       = module.vpc.subnet_route_table_association_ids
}

output "subnet_ids" {
  description = "IDs of all subnets"
  value       = module.vpc.subnet_ids
}

output "role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  value       = module.eks-cluster.eks_clusters["test"].arn

}
output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks-cluster.eks_clusters["test"].name
}

output "security_group_ids" {
  description = "IDs of security groups for the EKS cluster"
  value       = module.vpc.security_group_id

}