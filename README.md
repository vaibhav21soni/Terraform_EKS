
# Terraform_EKS
=======
# AWS EKS Terraform Infrastructure

![AWS EKS](https://img.shields.io/badge/AWS_EKS-Terraform-orange)
![Terraform](https://img.shields.io/badge/Terraform-1.0+-blue)
![License](https://img.shields.io/badge/License-MIT-green)

A comprehensive Terraform project for deploying and managing production-ready Amazon EKS clusters with advanced networking, security, and autoscaling capabilities.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Module Documentation](#module-documentation)
- [Workflow](#workflow)
- [Customization](#customization)
- [Best Practices](#best-practices)
- [Contributing](#contributing)
- [License](#license)

## 🏗️ Architecture Overview

This project implements a production-grade EKS infrastructure with the following components:

- **VPC & Networking**: Custom VPC with public and private subnets across multiple AZs
- **EKS Cluster**: Managed Kubernetes control plane with OIDC integration
- **Node Groups**: Managed worker nodes with customizable instance types and scaling options
- **IAM**: Least-privilege IAM roles and policies for cluster components
- **Karpenter**: Advanced autoscaling for optimized resource utilization
- **Add-ons**: Support for essential EKS add-ons (CoreDNS, kube-proxy, VPC CNI, etc.)

## ✨ Features

- **Modular Design**: Reusable modules for each infrastructure component
- **Multi-Environment Support**: Configure different environments using Terraform workspaces
- **Scalability**: Easily scale node groups and clusters based on workload demands
- **Security**: Follows AWS security best practices with proper IAM permissions
- **Flexibility**: Extensive configuration options for all components
- **Maintainability**: Well-structured code with consistent patterns
- **Observability**: Ready for integration with monitoring and logging solutions

## 🔧 Prerequisites

- Terraform v1.0+
- AWS CLI v2.0+ configured with appropriate permissions
- kubectl (for interacting with the cluster post-deployment)
- AWS account with permissions to create EKS clusters and related resources

## 📁 Project Structure

```
terraform_eks/EKS-terraform/
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

## 🚀 Getting Started

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/terraform_eks.git
   cd terraform_eks
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Create a `terraform.tfvars` file with your configuration:
   ```hcl
   project_name = "my-eks-project"
   
   vpcs = {
     main = {
       cidr_block = "10.0.0.0/16"
       tags = {
         Environment = "Production"
       }
     }
   }
   
   eips_config = {
     nat1 = {
       domain = "vpc"
     }
   }
   
   # Add other variables as needed
   ```

4. Plan the deployment:
   ```bash
   terraform plan -out=tfplan
   ```

5. Apply the configuration:
   ```bash
   terraform apply tfplan
   ```

### Accessing the Cluster

After deployment, configure kubectl to access your cluster:

```bash
aws eks update-kubeconfig --name <cluster-name> --region <region>
kubectl get nodes
```

## 📚 Module Documentation

### VPC Module

The VPC module creates a complete networking stack including VPC, subnets, internet gateways, NAT gateways, route tables, and security groups.

**Key Features:**
- Support for multiple VPCs
- Public and private subnet configuration
- NAT gateways for private subnet connectivity
- Security groups with dynamic rules

### EKS Cluster Module

This module provisions the EKS control plane with comprehensive configuration options.

**Key Features:**
- OIDC provider integration for pod identity
- Support for multiple clusters
- Add-on management
- Advanced networking options

### IAM Role Module

Creates IAM roles and policies with proper permissions for EKS components.

**Key Features:**
- Custom policy creation
- AWS managed policy attachment
- Dynamic policy document generation

### Node Group Module

Manages EKS node groups for worker nodes.

**Key Features:**
- Multiple node group support
- Customizable instance types
- Auto-scaling configuration
- Taints and labels support

### Karpenter Module

Implements Karpenter for advanced cluster autoscaling.

**Key Features:**
- Helm chart deployment
- IAM role configuration
- Custom provisioner support

## 🔄 Workflow

The infrastructure deployment follows this workflow:

1. **VPC Creation**: Sets up the networking foundation
2. **IAM Role Creation**: Establishes necessary permissions
3. **EKS Cluster Deployment**: Creates the Kubernetes control plane
4. **Node Group Provisioning**: Adds worker nodes to the cluster
5. **Add-on Installation**: Configures essential cluster add-ons
6. **Karpenter Setup**: Implements advanced autoscaling

## 🛠️ Customization

### Adding New Node Groups

To add a new node group, update the `local.tf` file:

```hcl
node_groups = {
  standard = {
    cluster_name  = module.eks-cluster.eks_clusters["test"].name
    node_role_arn = module.iam_role.output_iam_role_arns["node_group_role"]
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

### Configuring Karpenter

Update the Karpenter configuration in `local.tf`:

```hcl
karpenter_configs = {
  main = {
    name             = "karpenter-main"
    namespace        = "karpenter"
    chart            = "karpenter"
    repository       = "oci://public.ecr.aws/karpenter"
    version          = "0.37.0"
    create_namespace = true
    values           = ["${file("${path.module}/karpenter-values.yaml")}"]
  }
}
```

## 🏆 Best Practices

This project follows these Terraform best practices:

1. **Modular Design**: Each component is in its own module for reusability
2. **State Management**: Prepared for remote state with S3 and DynamoDB
3. **Variable Typing**: Strong typing with validation rules
4. **Resource Naming**: Consistent naming conventions
5. **Security**: Least privilege IAM policies
6. **Documentation**: Comprehensive comments and documentation

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

