# EKS Cluster Module

This module provisions and manages Amazon EKS clusters with comprehensive configuration options, OIDC provider integration, and add-on management.

## Features

- Support for multiple EKS clusters using `for_each`
- OIDC provider integration for pod identity and service accounts
- EKS add-on management (CoreDNS, kube-proxy, VPC CNI, etc.)
- Advanced cluster configuration options
- Validation rules for input parameters
- Support for various authentication modes
- Encryption configuration
- Network customization

## Usage

```hcl
module "eks-cluster" {
  source = "./modules/eks-cluster"
  
  project_name = "my-eks-project"
  
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
      tags = {
        Environment = "Production"
      }
    }
  }
  
  eks_oidc_providers = {
    main = {
      cluster_name    = "production-cluster"
      client_id_list  = ["sts.amazonaws.com"]
      tags = {
        Environment = "Production"
      }
    }
  }
  
  eks_addons = {
    vpc-cni = {
      cluster_name                = module.eks-cluster.eks_clusters["main"].name
      addon_name                  = "vpc-cni"
      addon_version               = "v1.12.6-eksbuild.2"
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "PRESERVE"
      service_account_role_arn    = module.iam_role.output_iam_role_arns["vpc_cni_role"]
      tags = {
        Addon = "vpc-cni"
      }
    }
    coredns = {
      cluster_name                = module.eks-cluster.eks_clusters["main"].name
      addon_name                  = "coredns"
      addon_version               = "v1.10.1-eksbuild.4"
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "PRESERVE"
      tags = {
        Addon = "coredns"
      }
    }
    kube-proxy = {
      cluster_name                = module.eks-cluster.eks_clusters["main"].name
      addon_name                  = "kube-proxy"
      addon_version               = "v1.28.2-eksbuild.2"
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "PRESERVE"
      tags = {
        Addon = "kube-proxy"
      }
    }
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| `project_name` | Name of the project for resource naming and tagging | `string` | yes |
| `eks_clusters` | Map of EKS cluster configurations | `map(object)` | yes |
| `eks_oidc_providers` | Map of EKS OIDC provider configurations | `map(object)` | no |
| `eks_addons` | Map of EKS add-ons to install | `map(object)` | no |

### eks_clusters Object Structure

```hcl
{
  name     = string
  role_arn = string
  vpc_config = object({
    subnet_ids              = list(string)
    endpoint_private_access = optional(bool, false)
    endpoint_public_access  = optional(bool, true)
    public_access_cidrs     = optional(list(string))
    security_group_ids      = optional(list(string))
  })
  version                       = optional(string)
  enabled_cluster_log_types     = optional(list(string))
  encryption_config             = optional(object(...))
  kubernetes_network_config     = optional(object(...))
  access_config                 = optional(object(...))
  # Additional optional parameters...
}
```

### eks_oidc_providers Object Structure

```hcl
{
  cluster_name    = string
  client_id_list  = optional(list(string), ["sts.amazonaws.com"])
  thumbprint_list = optional(list(string))
  tags            = optional(map(string), {})
}
```

### eks_addons Object Structure

```hcl
{
  cluster_name                = string
  addon_name                  = string
  addon_version               = optional(string)
  resolve_conflicts           = optional(string, "OVERWRITE")
  resolve_conflicts_on_create = optional(string, "OVERWRITE")
  resolve_conflicts_on_update = optional(string, "PRESERVE")
  service_account_role_arn    = optional(string)
  tags                        = optional(map(string), {})
}
```

## Outputs

| Name | Description |
|------|-------------|
| `eks_clusters` | Map of EKS cluster resources |
| `eks_cluster_names` | Map of EKS cluster names |
| `eks_cluster_endpoints` | Map of EKS cluster API server endpoints |
| `eks_cluster_certificate_authorities` | Map of EKS cluster certificate authority data |
| `eks_cluster_security_group_ids` | Map of EKS cluster security group IDs |
| `eks_cluster_oidc_issuer_urls` | Map of EKS cluster OIDC issuer URLs |

## Best Practices

1. **Private Endpoint Access**: Enable `endpoint_private_access` and restrict `public_access_cidrs` for better security.

2. **Cluster Logging**: Enable cluster logging with `enabled_cluster_log_types` for better observability:
   ```hcl
   enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
   ```

3. **OIDC Integration**: Always set up OIDC provider for pod identity and service accounts.

4. **Add-on Management**: Use the EKS add-on system for managing critical components like CoreDNS, kube-proxy, and VPC CNI.

5. **Version Strategy**: Specify the Kubernetes version explicitly and plan for regular upgrades.

6. **Encryption**: Consider enabling envelope encryption for secrets:
   ```hcl
   encryption_config = {
     provider = {
       key_arn = aws_kms_key.eks_secrets.arn
     }
     resources = ["secrets"]
   }
   ```

7. **Network Configuration**: Configure the Kubernetes service CIDR to avoid overlaps with your VPC:
   ```hcl
   kubernetes_network_config = {
     service_ipv4_cidr = "172.20.0.0/16"
   }
   ```
