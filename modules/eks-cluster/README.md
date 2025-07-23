# ☸️ EKS Cluster Module

<div align="center">
  <br>
  
  ![AWS EKS](https://img.shields.io/badge/AWS_EKS-Module-orange?style=for-the-badge)
  ![Terraform](https://img.shields.io/badge/Terraform-1.0+-blue?style=for-the-badge)
</div>

<p align="center">
  <i>A powerful Terraform module for provisioning and managing Amazon EKS clusters with comprehensive configuration options.</i>
</p>

---

## ✨ Features

- **🔄 Multiple Clusters** - Support for multiple EKS clusters using `for_each`
- **🔐 OIDC Integration** - Built-in OIDC provider for pod identity and service accounts
- **🧩 Add-on Management** - Streamlined management of EKS add-ons
- **🌐 Advanced Networking** - Flexible networking configuration options
- **🔒 Security Controls** - Comprehensive security settings
- **🔍 Validation Rules** - Input validation for error prevention

---

## 🚀 Usage

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

---

## 📋 Inputs

<div align="center">

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| `project_name` | Name of the project for resource naming and tagging | `string` | ✅ |
| `eks_clusters` | Map of EKS cluster configurations | `map(object)` | ✅ |
| `eks_oidc_providers` | Map of EKS OIDC provider configurations | `map(object)` | ❌ |
| `eks_addons` | Map of EKS add-ons to install | `map(object)` | ❌ |

</div>

### 🔍 eks_clusters Object Structure

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

### 🔍 eks_oidc_providers Object Structure

```hcl
{
  cluster_name    = string
  client_id_list  = optional(list(string), ["sts.amazonaws.com"])
  thumbprint_list = optional(list(string))
  tags            = optional(map(string), {})
}
```

### 🔍 eks_addons Object Structure

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

---

## 📤 Outputs

<div align="center">

| Name | Description |
|------|-------------|
| `eks_clusters` | Map of EKS cluster resources |
| `eks_cluster_names` | Map of EKS cluster names |
| `eks_cluster_endpoints` | Map of EKS cluster API server endpoints |
| `eks_cluster_certificate_authorities` | Map of EKS cluster certificate authority data |
| `eks_cluster_security_group_ids` | Map of EKS cluster security group IDs |
| `eks_cluster_oidc_issuer_urls` | Map of EKS cluster OIDC issuer URLs |

</div>

---

## 🏆 Best Practices

### 🔒 Private Endpoint Access

Enable `endpoint_private_access` and restrict `public_access_cidrs` for better security:

```hcl
vpc_config = {
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["10.0.0.0/8", "172.16.0.0/12"]
}
```

### 📊 Cluster Logging

Enable cluster logging with `enabled_cluster_log_types` for better observability:

```hcl
enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
```

### 🔐 OIDC Integration

Always set up OIDC provider for pod identity and service accounts:

```hcl
eks_oidc_providers = {
  main = {
    cluster_name   = "production-cluster"
    client_id_list = ["sts.amazonaws.com"]
  }
}
```

### 🧩 Add-on Management

Use the EKS add-on system for managing critical components:

```hcl
eks_addons = {
  vpc-cni = {
    cluster_name  = "production-cluster"
    addon_name    = "vpc-cni"
    addon_version = "v1.12.6-eksbuild.2"
  }
}
```

### 🔢 Version Strategy

Specify the Kubernetes version explicitly and plan for regular upgrades:

```hcl
version = "1.28"
```

### 🔐 Encryption

Enable envelope encryption for secrets:

```hcl
encryption_config = {
  provider = {
    key_arn = aws_kms_key.eks_secrets.arn
  }
  resources = ["secrets"]
}
```

### 🌐 Network Configuration

Configure the Kubernetes service CIDR to avoid overlaps with your VPC:

```hcl
kubernetes_network_config = {
  service_ipv4_cidr = "172.20.0.0/16"
}
```

---

<div align="center">
  <p>Built with ❤️ for the Kubernetes community</p>
</div>
