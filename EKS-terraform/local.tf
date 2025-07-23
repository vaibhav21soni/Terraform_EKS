locals {
  //vpc configuration
  nat_gateway_config = {
    test = {
      eip_key    = "test"
      subnet_key = "test"
      tags = {
        Name = "test-nat-gateway"
      }
    }
  }

  route_tables = {
    test = {
      vpc_id     = module.vpc.vpc_id["test"]
      name       = "test-route-table"
      gateway_id = module.vpc.internet_gateway_id["test"]
      nat_id     = module.vpc.nat_gateway_ids["test"]
      tags = {
        Name = "test-route-table"
      }
    }
  }

  subnet_route_table_associations = {
    test = {
      subnet_key      = "test"
      route_table_key = "test"
    }
  }

  security_groups = {
    eks_cluster_sg = {
      name        = "eks-cluster-sg"
      description = "Security group for EKS cluster"
      vpc_id      = module.vpc.vpc_id["test"]
      ingress = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
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
  } }

  // EKS Cluster configuration
  eks_clusters = {
    test = {
      name     = "test"
      role_arn = module.iam_role.output_iam_role_arns["test"]
      vpc_id   = module.vpc.vpc_id["test"]
      vpc_config = {
        subnet_ids         = [module.vpc.subnet_ids["test"]]
        security_group_ids = [module.vpc.security_group_id["eks_cluster_sg"]]
      }
    }

  }
  // EKS OIDC Providers configuration
  eks_oidc_providers = {
    test = {
      cluster_name    = "test"
      url             = module.eks-cluster.eks_clusters["test"].endpoint
      arn             = module.eks-cluster.eks_clusters["test"].arn
      thumbprint_list = [module.eks-cluster.eks_clusters["test"].certificate_authority[0].data]
      client_id_list  = ["sts.amazonaws.com"]
      tags = {
        Name        = "test-oidc-provider"
        Environment = "test"
      }

  } }
  // EKS Addons configuration
  eks_addons = {
    test = {
      name                        = "test-addon"
      addon_name                  = "test-addon"
      cluster_name                = module.eks-cluster.eks_clusters["test"].name
      service_account_role_arn    = module.iam_role.output_iam_role_arns["test"]
      resolve_conflicts           = "OVERWRITE"
      configuration_values        = null
      pod_identity_association    = null
      preserve                    = false
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version               = "v1.0.0"
      tags = {
        Name        = "test-addon"
        Environment = "test"
      }
    }
  }

  // Example IAM policy definitions
  iam_policy_definitions = {
    test = {
      name        = "test-policy"
      description = "Test IAM policy"
      statements = [
        {
          effect    = "Allow"
          actions   = ["s3:ListBucket"]
          resources = ["arn:aws:s3:::example-bucket"]
        },
        {
          effect    = "Allow"
          actions   = ["s3:GetObject"]
          resources = ["arn:aws:s3:::example-bucket/*"]
        }
      ]
    }
  }
  iam_roles = {
    test = {
      name    = "test-role"
      service = "eks"
      # either remove the line below, or provide a valid jsonencode
      assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
          Effect = "Allow",
          Principal = {
            Service = "eks.amazonaws.com"
          },
          Action = "sts:AssumeRole"
        }]
      })
      tags = {
        Name        = "test-role"
        Environment = "test"
      }
    }
  }
  iam_roles_attachments = {
    test = {
      role_key   = "test"
      policy_key = "test"
    }
  }
  iam_roles_aws_managed_attachments = {
    test = {
      role_key   = "test"
      policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    }
  }
  // VPC configuration
  vpc_igw = {
    test = {
      vpc_id = module.vpc.vpc_id["test"]
      tags = {
        Name        = "test-igw"
        Environment = "test"
      }
    }
  }


  // Karpenter configurations
  karpenter_configs = {
    test = {
      name             = "karpenter-test"
      namespace        = "karpenter"
      chart            = "karpenter"
      repository       = "oci://public.ecr.aws/karpenter"
      version          = "0.37.0"
      create_namespace = true
      values           = []
      additional_sets  = []
    }
  }
  subnets = {
    test = {
      az         = "us-west-2a"
      cidr_block = "10.0.1.0/24"
      public     = true
      vpc_id     = module.vpc.vpc_id["test"]
      tags = {
        Name        = "test-subnet"
        Environment = "test"
      }

    }
  }
}