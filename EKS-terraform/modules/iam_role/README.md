# IAM Role Module

This module creates and manages IAM roles and policies for your EKS cluster components, following the principle of least privilege.

## Features

- Dynamic IAM role creation with customizable trust relationships
- Custom IAM policy definition and attachment
- AWS managed policy attachment
- Support for complex policy statements with conditions
- Proper output of role ARNs and names for use in other modules

## Usage

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

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| `iam_policy_definitions` | Map of IAM policy definitions | `map(object)` | no |
| `iam_roles` | Map of IAM roles to create | `map(object)` | yes |
| `iam_roles_attachments` | Map of role to custom policy attachments | `map(object)` | no |
| `iam_roles_aws_managed_attachments` | Map of role to AWS managed policy attachments | `map(object)` | no |

### iam_policy_definitions Object Structure

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

### iam_roles Object Structure

```hcl
{
  name               = string
  assume_role_policy = optional(string)
  tags               = optional(map(string))
}
```

### iam_roles_attachments Object Structure

```hcl
{
  role_key   = string
  policy_key = string
}
```

### iam_roles_aws_managed_attachments Object Structure

```hcl
{
  role_key   = string
  policy_arn = string
}
```

## Outputs

| Name | Description |
|------|-------------|
| `output_iam_role_arns` | Map of IAM role ARNs |
| `output_iam_role_names` | Map of IAM role names |
| `output_iam_role_policies` | Map of IAM role policies |

## Best Practices

1. **Least Privilege**: Always follow the principle of least privilege when defining IAM policies.

2. **Role Separation**: Create separate roles for different components (cluster, nodes, add-ons).

3. **Managed Policies**: Use AWS managed policies where appropriate, but be aware of their scope.

4. **Custom Policies**: Create custom policies for specific requirements to avoid overly permissive access.

5. **Policy Conditions**: Use conditions to further restrict when policies can be used.

6. **Documentation**: Document the purpose of each role and policy in tags and descriptions.

7. **Regular Review**: Regularly review and audit IAM roles and policies to ensure they remain appropriate.

## Common IAM Roles for EKS

1. **EKS Cluster Role**: Needs `AmazonEKSClusterPolicy`

2. **EKS Node Role**: Needs:
   - `AmazonEKSWorkerNodePolicy`
   - `AmazonEKS_CNI_Policy`
   - `AmazonEC2ContainerRegistryReadOnly`

3. **Load Balancer Controller Role**: Needs permissions to manage load balancers, target groups, and listeners.

4. **External DNS Role**: Needs permissions to manage Route53 records.

5. **Cluster Autoscaler Role**: Needs permissions to describe and modify Auto Scaling Groups.

6. **Karpenter Role**: Needs permissions to provision and manage EC2 instances.
