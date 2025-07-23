# 🔐 IAM Role Module

<div align="center">
  <br>
  
  ![AWS IAM](https://img.shields.io/badge/AWS_IAM-Module-orange?style=for-the-badge)
  ![Terraform](https://img.shields.io/badge/Terraform-1.0+-blue?style=for-the-badge)
</div>

<p align="center">
  <i>A powerful Terraform module for creating and managing IAM roles and policies for your EKS cluster components, following the principle of least privilege.</i>
</p>

---

## ✨ Features

- **🔄 Dynamic Role Creation** - Customizable trust relationships
- **📝 Custom Policy Definition** - Create tailored policies for your needs
- **🔗 Policy Attachment** - Attach custom and AWS managed policies
- **🛡️ Least Privilege** - Follow security best practices
- **🧩 Complex Policy Support** - Support for conditions and multiple statements
- **📤 Comprehensive Outputs** - Easy access to role ARNs and names

---

## 🚀 Usage

```hcl
module "iam_role" {
  source = "./modules/iam_role"
  
  iam_policy_definitions = {
    eks_node_policy = {
      description = "Custom policy for EKS nodes"
      statements = [
        {
          effect    = "Allow"
          actions   = [
            "ec2:DescribeInstances",
            "ec2:DescribeRouteTables",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeVolumes"
          ]
          resources = ["*"]
        },
        {
          effect    = "Allow"
          actions   = [
            "ec2:CreateTags",
            "ec2:DeleteTags"
          ]
          resources = ["arn:aws:ec2:*:*:instance/*"]
        }
      ]
      tags = {
        Purpose = "EKS Node Management"
      }
    }
  }
  
  iam_roles = {
    eks_cluster_role = {
      name = "eks-cluster-role"
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
        Purpose = "EKS Cluster Management"
      }
    },
    eks_node_role = {
      name = "eks-node-role"
      assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
          Effect = "Allow",
          Principal = {
            Service = "ec2.amazonaws.com"
          },
          Action = "sts:AssumeRole"
        }]
      })
      tags = {
        Purpose = "EKS Node Management"
      }
    }
  }
  
  iam_roles_attachments = {
    node_custom_policy = {
      role_key   = "eks_node_role"
      policy_key = "eks_node_policy"
    }
  }
  
  iam_roles_aws_managed_attachments = {
    cluster_policy = {
      role_key   = "eks_cluster_role"
      policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    },
    node_worker_policy = {
      role_key   = "eks_node_role"
      policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    },
    node_cni_policy = {
      role_key   = "eks_node_role"
      policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    },
    node_ecr_policy = {
      role_key   = "eks_node_role"
      policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    }
  }
}
```

---

## 📋 Inputs

<div align="center">

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| `iam_policy_definitions` | Map of IAM policy definitions | `map(object)` | ❌ |
| `iam_roles` | Map of IAM roles to create | `map(object)` | ✅ |
| `iam_roles_attachments` | Map of role to custom policy attachments | `map(object)` | ❌ |
| `iam_roles_aws_managed_attachments` | Map of role to AWS managed policy attachments | `map(object)` | ❌ |

</div>

### 🔍 iam_policy_definitions Object Structure

```hcl
{
  description = optional(string)
  statements = list(object({
    sid       = optional(string)
    effect    = optional(string)
    actions   = list(string)
    resources = list(string)
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    conditions = optional(map(map(string)))
  }))
  tags = optional(map(string))
}
```

### 🔍 iam_roles Object Structure

```hcl
{
  name               = string
  assume_role_policy = optional(string)
  tags               = optional(map(string))
}
```

### 🔍 iam_roles_attachments Object Structure

```hcl
{
  role_key   = string
  policy_key = string
}
```

### 🔍 iam_roles_aws_managed_attachments Object Structure

```hcl
{
  role_key   = string
  policy_arn = string
}
```

---

## 📤 Outputs

<div align="center">

| Name | Description |
|------|-------------|
| `output_iam_role_arns` | Map of IAM role ARNs |
| `output_iam_role_names` | Map of IAM role names |
| `output_iam_role_policies` | Map of IAM role policies |

</div>

---

## 🏆 Best Practices

### 🛡️ Least Privilege

Always follow the principle of least privilege when defining IAM policies:

```hcl
statements = [
  {
    effect    = "Allow"
    actions   = [
      "ec2:DescribeInstances",
      "ec2:DescribeRouteTables"
    ]
    resources = ["*"]
  }
]
```

### 🧩 Role Separation

Create separate roles for different components:

```hcl
iam_roles = {
  eks_cluster_role = { ... },
  eks_node_role = { ... },
  service_account_role = { ... }
}
```

### 📚 Managed Policies

Use AWS managed policies where appropriate, but be aware of their scope:

```hcl
iam_roles_aws_managed_attachments = {
  cluster_policy = {
    role_key   = "eks_cluster_role"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  }
}
```

### 🔒 Custom Policies

Create custom policies for specific requirements to avoid overly permissive access:

```hcl
iam_policy_definitions = {
  custom_policy = {
    description = "Custom policy with specific permissions"
    statements = [ ... ]
  }
}
```

### 🔍 Policy Conditions

Use conditions to further restrict when policies can be used:

```hcl
conditions = {
  "StringEquals" = {
    "aws:SourceVpc" = "vpc-12345678"
  }
}
```

### 📝 Documentation

Document the purpose of each role and policy in tags and descriptions:

```hcl
tags = {
  Purpose = "EKS Cluster Management"
  Owner   = "Platform Team"
}
```

### 🔄 Regular Review

Regularly review and audit IAM roles and policies to ensure they remain appropriate.

---

## 🧩 Common IAM Roles for EKS

<div align="center">

| Role | Purpose | Required Policies |
|------|---------|-------------------|
| **EKS Cluster Role** | Manage EKS control plane | AmazonEKSClusterPolicy |
| **EKS Node Role** | Allow worker nodes to join cluster | AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly |
| **Load Balancer Controller Role** | Manage AWS load balancers | Custom policy for ALB/NLB management |
| **External DNS Role** | Manage Route53 records | Custom policy for Route53 management |
| **Cluster Autoscaler Role** | Scale node groups | Custom policy for ASG management |

</div>

---

<div align="center">
  <p>Built with ❤️ for secure Kubernetes deployments</p>
</div>
