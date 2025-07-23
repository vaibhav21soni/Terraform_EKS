
# 1 - Creating VPC
module "vpc" {
  source                          = "./modules/vpc"
  vpcs                            = var.vpcs
  eips_config                     = var.eips_config
  security_groups                 = local.security_groups
  subnets                         = local.subnets
  route_tables                    = local.route_tables
  subnet_route_table_associations = local.subnet_route_table_associations
  project_name                    = var.project_name
  nat_gateway_config              = local.nat_gateway_config
  vpc_igw                         = local.vpc_igw

}





# 2 - Create IAM Roles
module "iam_role" {
  source                            = "./modules/iam_role"
  iam_roles                         = local.iam_roles
  iam_roles_attachments             = local.iam_roles_attachments
  iam_policy_definitions            = local.iam_policy_definitions
  iam_roles_aws_managed_attachments = local.iam_roles_aws_managed_attachments
}

# 3 - create Eks Cluster
module "eks-cluster" {
  source             = "./modules/eks-cluster"
  eks_clusters       = local.eks_clusters
  eks_oidc_providers = local.eks_oidc_providers
  eks_addons         = local.eks_addons

  project_name = var.project_name




}

