# Local values for resource configuration
locals {
  # Common tags applied to all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Workspace   = terraform.workspace
    ManagedBy   = "Terraform"
  }

  # Cluster name with workspace support
  cluster_name = "${var.project_name}-${terraform.workspace}"

  # Get VPC key dynamically (first VPC in the map)
  vpc_key = keys(var.vpcs)[0]

  # VPC and Networking Configuration
  vpc_igw = {
    for vpc_key, vpc_config in var.vpcs : vpc_key => {
      vpc_id = vpc_key
      tags = merge(local.common_tags, {
        Name = "${var.project_name}-${terraform.workspace}-igw"
      })
    }
  }

  # Subnets configuration - dynamically create based on VPC CIDR
  subnets = {
    public_1 = {
      vpc_id                  = local.vpc_key
      cidr_block             = cidrsubnet(var.vpcs[local.vpc_key].cidr_block, 8, 1)
      az                     = data.aws_availability_zones.available.names[0]
      public                 = true
      tags = merge(local.common_tags, {
        Name                     = "${var.project_name}-${terraform.workspace}-public-1"
        Type                     = "Public"
        "kubernetes.io/role/elb" = "1"
        "kubernetes.io/cluster/${local.cluster_name}" = "shared"
      })
    }
    public_2 = {
      vpc_id                  = local.vpc_key
      cidr_block             = cidrsubnet(var.vpcs[local.vpc_key].cidr_block, 8, 2)
      az                     = data.aws_availability_zones.available.names[1]
      public                 = true
      tags = merge(local.common_tags, {
        Name                     = "${var.project_name}-${terraform.workspace}-public-2"
        Type                     = "Public"
        "kubernetes.io/role/elb" = "1"
        "kubernetes.io/cluster/${local.cluster_name}" = "shared"
      })
    }
    private_1 = {
      vpc_id            = local.vpc_key
      cidr_block        = cidrsubnet(var.vpcs[local.vpc_key].cidr_block, 8, 10)
      az                = data.aws_availability_zones.available.names[0]
      public            = false
      tags = merge(local.common_tags, {
        Name                              = "${var.project_name}-${terraform.workspace}-private-1"
        Type                              = "Private"
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/cluster/${local.cluster_name}" = "owned"
      })
    }
    private_2 = {
      vpc_id            = local.vpc_key
      cidr_block        = cidrsubnet(var.vpcs[local.vpc_key].cidr_block, 8, 11)
      az                = data.aws_availability_zones.available.names[1]
      public            = false
      tags = merge(local.common_tags, {
        Name                              = "${var.project_name}-${terraform.workspace}-private-2"
        Type                              = "Private"
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/cluster/${local.cluster_name}" = "owned"
      })
    }
  }

  # Get EIP keys dynamically
  eip_keys = keys(var.eips_config)

  # NAT Gateway configuration - dynamically reference EIPs
  nat_gateway_config = {
    nat_1 = {
      subnet_key = "public_1"
      eip_key    = length(local.eip_keys) > 0 ? local.eip_keys[0] : "nat1"
      tags = merge(local.common_tags, {
        Name = "${var.project_name}-${terraform.workspace}-nat-1"
      })
    }
    nat_2 = {
      subnet_key = "public_2"
      eip_key    = length(local.eip_keys) > 1 ? local.eip_keys[1] : "nat2"
      tags = merge(local.common_tags, {
        Name = "${var.project_name}-${terraform.workspace}-nat-2"
      })
    }
  }

  # Route Tables configuration
  route_tables = {
    public = {
      vpc_id     = local.vpc_key
      name       = "${var.project_name}-${terraform.workspace}-public-rt"
      gateway_id = local.vpc_key
      tags = merge(local.common_tags, {
        Name = "${var.project_name}-${terraform.workspace}-public-rt"
        Type = "Public"
      })
    }
    private_1 = {
      vpc_id = local.vpc_key
      name   = "${var.project_name}-${terraform.workspace}-private-rt-1"
      nat_id = "nat_1"
      tags = merge(local.common_tags, {
        Name = "${var.project_name}-${terraform.workspace}-private-rt-1"
        Type = "Private"
      })
    }
    private_2 = {
      vpc_id = local.vpc_key
      name   = "${var.project_name}-${terraform.workspace}-private-rt-2"
      nat_id = "nat_2"
      tags = merge(local.common_tags, {
        Name = "${var.project_name}-${terraform.workspace}-private-rt-2"
        Type = "Private"
      })
    }
  }

  # Subnet Route Table Associations
  subnet_route_table_associations = {
    public_1_association = {
      subnet_key      = "public_1"
      route_table_key = "public"
    }
    public_2_association = {
      subnet_key      = "public_2"
      route_table_key = "public"
    }
    private_1_association = {
      subnet_key      = "private_1"
      route_table_key = "private_1"
    }
    private_2_association = {
      subnet_key      = "private_2"
      route_table_key = "private_2"
    }
  }

  # Security Groups configuration
  security_groups = {
    eks_cluster_sg = {
      vpc_id      = local.vpc_key
      name        = "${var.project_name}-${terraform.workspace}-eks-cluster-sg"
      description = "Security group for EKS cluster control plane"
      
      ingress = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = [var.vpcs[local.vpc_key].cidr_block]
        }
      ]
      
      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      
      tags = merge(local.common_tags, {
        Name = "${var.project_name}-${terraform.workspace}-eks-cluster-sg"
      })
    }
    
    eks_node_sg = {
      vpc_id      = local.vpc_key
      name        = "${var.project_name}-${terraform.workspace}-eks-node-sg"
      description = "Security group for EKS worker nodes"
      
      ingress = [
        {
          from_port   = 0
          to_port     = 65535
          protocol    = "tcp"
          cidr_blocks = [var.vpcs[local.vpc_key].cidr_block]
        },
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = [var.vpcs[local.vpc_key].cidr_block]
        }
      ]
      
      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      
      tags = merge(local.common_tags, {
        Name = "${var.project_name}-${terraform.workspace}-eks-node-sg"
      })
    }
  }

  # IAM Roles configuration
  iam_roles = {
    eks_cluster_role = {
      name = "${var.project_name}-${terraform.workspace}-eks-cluster-role"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "eks.amazonaws.com"
            }
          }
        ]
      })
      tags = local.common_tags
    }
    
    eks_node_role = {
      name = "${var.project_name}-${terraform.workspace}-eks-node-role"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "ec2.amazonaws.com"
            }
          }
        ]
      })
      tags = local.common_tags
    }
  }

  # IAM Role AWS Managed Policy Attachments
  iam_roles_aws_managed_attachments = {
    eks_cluster_policy = {
      role_key   = "eks_cluster_role"
      policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    }
    eks_node_worker_policy = {
      role_key   = "eks_node_role"
      policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    }
    eks_cni_policy = {
      role_key   = "eks_node_role"
      policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    }
    eks_container_registry_policy = {
      role_key   = "eks_node_role"
      policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    }
    eks_ebs_csi_policy = {
      role_key   = "eks_node_role"
      policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
  }

  # Custom IAM Policy Definitions
  iam_policy_definitions = {
    eks_cluster_logging_policy = {
      description = "Policy for EKS cluster logging"
      statements = [
        {
          effect = "Allow"
          actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams"
          ]
          resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
        }
      ]
      tags = local.common_tags
    }
  }

  # IAM Role Custom Policy Attachments
  iam_roles_attachments = {
    eks_cluster_logging_attachment = {
      role_key   = "eks_cluster_role"
      policy_key = "eks_cluster_logging_policy"
    }
  }

  # EKS Clusters configuration - resolved after IAM roles are created
  eks_clusters_resolved = {
    main = {
      name     = local.cluster_name
      role_arn = module.iam_role.output_iam_role_arns["eks_cluster_role"]
      version  = var.kubernetes_version
      
      vpc_config = {
        subnet_ids              = [for key in ["private_1", "private_2", "public_1", "public_2"] : module.vpc.subnet_ids[key]]
        endpoint_private_access = var.cluster_endpoint_private_access
        endpoint_public_access  = var.cluster_endpoint_public_access
        public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
        security_group_ids      = [for key in ["eks_cluster_sg"] : module.vpc.security_group_id[key]]
      }
      
      # Only include encryption_config if enabled
      encryption_config = var.enable_cluster_encryption ? {
        provider = {
          key_arn = "alias/aws/eks" # Use default AWS managed key
        }
        resources = ["secrets"]
      } : null
      
      enabled_cluster_log_types = var.cluster_log_types
      
      tags = merge(local.common_tags, {
        Name = local.cluster_name
      })
    }
  }

  # EKS Node Groups configuration - resolved after IAM roles are created
  eks_node_groups_resolved = {
    for name, config in var.node_groups : name => {
      cluster_name   = local.cluster_name
      node_role_arn  = module.iam_role.output_iam_role_arns["eks_node_role"]
      subnet_ids     = [for key in ["private_1", "private_2"] : module.vpc.subnet_ids[key]]
      instance_types = config.instance_types
      capacity_type  = config.capacity_type
      disk_size      = config.disk_size
      
      scaling_config = config.scaling_config
      update_config  = config.update_config
      
      tags = merge(local.common_tags, config.tags, {
        Name = "${local.cluster_name}-${name}-node-group"
      })
    }
  }

  # EKS OIDC Providers configuration
  eks_oidc_providers = {
    main = {
      cluster_name = local.cluster_name
      tags = merge(local.common_tags, {
        Name = "${local.cluster_name}-oidc-provider"
      })
    }
  }

  # EKS Add-ons configuration
  eks_addons = {
    for name, config in var.cluster_addons : name => {
      cluster_name      = local.cluster_name
      addon_name        = name
      addon_version     = config.addon_version
      resolve_conflicts = config.resolve_conflicts
      tags = merge(local.common_tags, config.tags, {
        Name = "${local.cluster_name}-${name}-addon"
      })
    }
  }
}
