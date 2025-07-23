# Node Group Module

This module manages EKS node groups, which provision and manage EC2 instances for your Kubernetes worker nodes.

## Features

- Support for multiple node groups with different configurations
- Customizable instance types and capacity types
- Auto-scaling configuration
- Support for taints and labels
- Update configuration for controlled node upgrades
- AMI type selection

## Usage

```hcl
module "node_group" {
  source = "./modules/node_group"
  
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
      disk_size      = 50
      ami_type       = "AL2_x86_64"
      
      labels = {
        "role" = "standard"
        "environment" = "production"
      }
      
      taint = [
        {
          key    = "dedicated"
          value  = "standard"
          effect = "NO_SCHEDULE"
        }
      ]
      
      update_config = {
        max_unavailable = 1
      }
      
      tags = {
        Name = "standard-node-group"
        Environment = "Production"
      }
    },
    
    spot = {
      cluster_name  = module.eks-cluster.eks_clusters["main"].name
      node_role_arn = module.iam_role.output_iam_role_arns["eks_node_role"]
      subnet_ids    = [module.vpc.subnet_ids["private1"], module.vpc.subnet_ids["private2"]]
      
      scaling_config = {
        desired_size = 3
        max_size     = 10
        min_size     = 1
      }
      
      instance_types = ["t3.large", "t3a.large", "m5.large", "m5a.large"]
      capacity_type  = "SPOT"
      
      labels = {
        "role" = "spot"
        "lifecycle" = "spot"
      }
      
      tags = {
        Name = "spot-node-group"
        Environment = "Production"
      }
    }
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| `eks_node_groups` | Map of EKS node group configurations | `map(object)` | yes |

### eks_node_groups Object Structure

```hcl
{
  cluster_name  = string
  node_role_arn = string
  subnet_ids    = list(string)
  scaling_config = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  instance_types         = optional(list(string))
  capacity_type          = optional(string)
  disk_size              = optional(number)
  ami_type               = optional(string)
  labels                 = optional(map(string))
  version                = optional(string)
  node_group_name        = optional(string)
  node_group_name_prefix = optional(string)
  tags                   = optional(map(string))
  taint = optional(list(object({
    key    = string
    value  = optional(string)
    effect = string
  })))
  update_config = optional(object({
    max_unavailable            = optional(number)
    max_unavailable_percentage = optional(number)
  }))
}
```

## Outputs

| Name | Description |
|------|-------------|
| `node_group_arns` | ARNs of the EKS Node Groups |
| `node_group_ids` | IDs of the EKS Node Groups |
| `node_group_status` | Status of the EKS Node Groups |

## Best Practices

1. **Instance Diversity**: For Spot instances, specify multiple instance types to increase availability.

2. **Capacity Type Selection**:
   - Use `ON_DEMAND` for critical workloads that require stability
   - Use `SPOT` for cost optimization on non-critical workloads

3. **Subnet Selection**: Place node groups in private subnets for better security.

4. **Scaling Configuration**: Set appropriate min/max/desired values based on your workload needs.

5. **Update Strategy**: Configure `update_config` to control how nodes are replaced during updates.

6. **Node Labels**: Use labels to identify node characteristics for workload scheduling.

7. **Taints**: Use taints to prevent certain workloads from being scheduled on specific nodes.

8. **Resource Optimization**: Choose appropriate instance types for your workloads to optimize cost and performance.

## Node Group Types

### General Purpose

```hcl
general_purpose = {
  instance_types = ["t3.medium", "t3a.medium"]
  labels = {
    "node-type" = "general-purpose"
  }
}
```

### Compute Optimized

```hcl
compute_optimized = {
  instance_types = ["c5.large", "c5a.large"]
  labels = {
    "node-type" = "compute-optimized"
  }
}
```

### Memory Optimized

```hcl
memory_optimized = {
  instance_types = ["r5.large", "r5a.large"]
  labels = {
    "node-type" = "memory-optimized"
  }
}
```

### GPU Instances

```hcl
gpu = {
  instance_types = ["g4dn.xlarge"]
  ami_type       = "AL2_x86_64_GPU"
  labels = {
    "node-type" = "gpu"
    "nvidia.com/gpu" = "true"
  }
}
```
