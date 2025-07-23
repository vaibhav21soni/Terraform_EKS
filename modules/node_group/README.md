# 🖥️ Node Group Module

<div align="center">
  <img src="https://d1.awsstatic.com/icons/console/manage/ec2.9c0e0d4c77b1be77a5a2b0b5695ee19a999b2aae.png" alt="EC2 Logo" width="150" height="150">
  <br>
  <br>
  
  ![AWS EKS](https://img.shields.io/badge/AWS_EKS-Node_Groups-orange?style=for-the-badge)
  ![Terraform](https://img.shields.io/badge/Terraform-1.0+-blue?style=for-the-badge)
</div>

<p align="center">
  <i>A powerful Terraform module for provisioning and managing EKS node groups, which provide the compute capacity for your Kubernetes workloads.</i>
</p>

---

## ✨ Features

- **🔄 Multiple Node Groups** - Support for various node group configurations
- **💻 Instance Flexibility** - Customizable instance types and capacity types
- **⚖️ Auto-scaling** - Built-in scaling configuration
- **🏷️ Labels & Taints** - Kubernetes node customization
- **🔄 Update Management** - Controlled node upgrades
- **💾 Storage Options** - Configurable disk sizes

---

## 🚀 Usage

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

---

## 📋 Inputs

<div align="center">

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| `eks_node_groups` | Map of EKS node group configurations | `map(object)` | ✅ |

</div>

### 🔍 eks_node_groups Object Structure

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

---

## 📤 Outputs

<div align="center">

| Name | Description |
|------|-------------|
| `node_group_arns` | ARNs of the EKS Node Groups |
| `node_group_ids` | IDs of the EKS Node Groups |
| `node_group_status` | Status of the EKS Node Groups |

</div>

---

## 🏆 Best Practices

### 💻 Instance Diversity

For Spot instances, specify multiple instance types to increase availability:

```hcl
instance_types = ["t3.large", "t3a.large", "m5.large", "m5a.large"]
```

### 🔋 Capacity Type Selection

- Use `ON_DEMAND` for critical workloads that require stability
- Use `SPOT` for cost optimization on non-critical workloads

```hcl
capacity_type = "ON_DEMAND"  # or "SPOT"
```

### 🔒 Subnet Selection

Place node groups in private subnets for better security:

```hcl
subnet_ids = [module.vpc.subnet_ids["private1"], module.vpc.subnet_ids["private2"]]
```

### ⚖️ Scaling Configuration

Set appropriate min/max/desired values based on your workload needs:

```hcl
scaling_config = {
  desired_size = 2
  max_size     = 5
  min_size     = 1
}
```

### 🔄 Update Strategy

Configure `update_config` to control how nodes are replaced during updates:

```hcl
update_config = {
  max_unavailable = 1
}
```

### 🏷️ Node Labels

Use labels to identify node characteristics for workload scheduling:

```hcl
labels = {
  "node-type" = "general-purpose"
  "environment" = "production"
}
```

### 🚫 Taints

Use taints to prevent certain workloads from being scheduled on specific nodes:

```hcl
taint = [
  {
    key    = "dedicated"
    value  = "gpu"
    effect = "NO_SCHEDULE"
  }
]
```

### 💰 Resource Optimization

Choose appropriate instance types for your workloads to optimize cost and performance:

```hcl
instance_types = ["t3.medium"]  # General purpose
# or
instance_types = ["c5.large"]   # Compute optimized
# or
instance_types = ["r5.large"]   # Memory optimized
```

---

## 🧩 Node Group Types

### 🌐 General Purpose

```hcl
general_purpose = {
  instance_types = ["t3.medium", "t3a.medium"]
  labels = {
    "node-type" = "general-purpose"
  }
}
```

### 🧮 Compute Optimized

```hcl
compute_optimized = {
  instance_types = ["c5.large", "c5a.large"]
  labels = {
    "node-type" = "compute-optimized"
  }
}
```

### 💾 Memory Optimized

```hcl
memory_optimized = {
  instance_types = ["r5.large", "r5a.large"]
  labels = {
    "node-type" = "memory-optimized"
  }
}
```

### 🎮 GPU Instances

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

---

<div align="center">
  <p>Built with ❤️ for scalable Kubernetes deployments</p>
</div>
