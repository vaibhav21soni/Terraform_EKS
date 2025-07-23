# EKS Terraform Infrastructure

A comprehensive Terraform project for deploying and managing production-ready Amazon EKS clusters with advanced networking, security, and autoscaling capabilities.

## Architecture

This project implements a modular approach to EKS infrastructure, with separate modules for:

- **VPC & Networking**: Custom VPC with public and private subnets
- **IAM Roles & Policies**: Least-privilege permissions for cluster components
- **EKS Cluster**: Managed Kubernetes control plane with OIDC integration
- **Node Groups**: Managed worker nodes with customizable configurations
- **Karpenter**: Advanced autoscaling for optimized resource utilization

## Module Structure

```
EKS-terraform/
├── data.tf                 # Data sources for EKS cluster
├── local.tf                # Local variables for configuration
├── main.tf                 # Main module instantiation
├── modules/                # Reusable modules
│   ├── eks-cluster/        # EKS cluster configuration
│   ├── iam_role/           # IAM roles and policies
│   ├── Karpenter/          # Karpenter autoscaling
│   ├── node_group/         # EKS node groups
│   └── vpc/                # VPC and networking
├── output.tf               # Output values
├── provider.tf             # Provider configuration
└── variables.tf            # Input variables
```

## Prerequisites

- Terraform v1.0+
- AWS CLI v2.0+ configured with appropriate permissions
- kubectl (for interacting with the cluster post-deployment)

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Create a `terraform.tfvars` file with your configuration:
   ```hcl
   project_name = "my-eks-project"
   
   vpcs = {
     test = {
       cidr_block = "10.0.0.0/16"
       tags = {
         Environment = "Test"
       }
     }
   }
   
   eips_config = {
     test = {
       domain = "vpc"
     }
   }
   ```

3. Plan the deployment:
   ```bash
   terraform plan -out=tfplan
   ```

4. Apply the configuration:
   ```bash
   terraform apply tfplan
   ```

5. Configure kubectl to access your cluster:
   ```bash
   aws eks update-kubeconfig --name <cluster-name> --region <region>
   ```

## Configuration

### VPC Configuration

```hcl
vpcs = {
  main = {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
  }
}

subnets = {
  public1 = {
    vpc_id     = module.vpc.vpc_id["main"]
    cidr_block = "10.0.1.0/24"
    az         = "us-west-2a"
    public     = true
    tags = {
      "kubernetes.io/role/elb" = "1"
    }
  }
  private1 = {
    vpc_id     = module.vpc.vpc_id["main"]
    cidr_block = "10.0.2.0/24"
    az         = "us-west-2a"
    public     = false
    tags = {
      "kubernetes.io/role/internal-elb" = "1"
    }
  }
}
```

### EKS Cluster Configuration

```hcl
eks_clusters = {
  main = {
    name     = "production-cluster"
    role_arn = module.iam_role.output_iam_role_arns["eks_cluster_role"]
    vpc_config = {
      subnet_ids              = [module.vpc.subnet_ids["private1"], module.vpc.subnet_ids["private2"]]
      endpoint_private_access = true
      endpoint_public_access  = true
      public_access_cidrs     = ["10.0.0.0/8", "172.16.0.0/12"]
      security_group_ids      = [module.vpc.security_group_id["eks_cluster_sg"]]
    }
    version = "1.28"
  }
}
```

### Node Group Configuration

```hcl
eks_node_groups = {
  standard = {
    cluster_name  = module.eks-cluster.eks_clusters["main"].name
    node_role_arn = module.iam_role.output_iam_role_arns["eks_node_role"]
    subnet_ids    = [module.vpc.subnet_ids["private1"], module.vpc.subnet_ids["private2"]]
    
    scaling_config = {
      desired_size = 2
      max_size     = 5
      min_size     = 1
    }
    
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
  }
}
```

### Karpenter Configuration

```hcl
karpenter_configs = {
  main = {
    name             = "karpenter"
    namespace        = "karpenter"
    chart            = "karpenter"
    repository       = "oci://public.ecr.aws/karpenter"
    version          = "0.37.0"
    create_namespace = true
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | Map of VPC IDs |
| `subnet_ids` | Map of subnet IDs |
| `eks_cluster_name` | Name of the EKS cluster |
| `role_arn` | ARN of the IAM role for the EKS cluster |
| `security_group_ids` | IDs of security groups for the EKS cluster |

## Best Practices

1. **State Management**: Use remote state with S3 and DynamoDB for team environments.

2. **Environment Separation**: Use Terraform workspaces or separate state files for different environments.

3. **Security**: Follow the principle of least privilege for IAM roles and restrict security group rules.

4. **High Availability**: Deploy resources across multiple availability zones.

5. **Cost Optimization**: Use Spot instances where appropriate and leverage Karpenter for efficient autoscaling.

6. **Documentation**: Keep documentation up-to-date with any changes to the infrastructure.

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

