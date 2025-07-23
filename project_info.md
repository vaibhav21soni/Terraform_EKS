# 🌟 EKS Terraform Infrastructure - Project Information

<div align="center">
  <img src="https://d1.awsstatic.com/icons/console/manage/eks.8dd6da65dd3875d11ce13c2cae82140de89c9f78.png" alt="EKS Logo" width="150" height="150">
</div>

## 🔍 Project Overview

This project provides a comprehensive Terraform solution for deploying and managing Amazon EKS (Elastic Kubernetes Service) clusters with advanced networking, security, and scalability features. It follows infrastructure-as-code best practices and modular design principles to create production-ready Kubernetes environments on AWS.

> *"Infrastructure as code with the power of Kubernetes orchestration"*

---

## 🏗️ Architecture Design

<div align="center">
  <img src="https://via.placeholder.com/800x400?text=EKS+Architecture+Diagram" alt="Architecture Diagram" width="800">
</div>

The architecture follows a multi-tier design with clear separation of concerns:

### 🌐 Networking Layer

| Component | Description |
|-----------|-------------|
| **VPC** | Isolated network environment with custom CIDR block |
| **Subnets** | Public and private subnets across multiple availability zones |
| **Internet Gateway** | Provides internet connectivity for public subnets |
| **NAT Gateways** | Enable outbound internet access from private subnets |
| **Route Tables** | Control traffic flow between subnets and gateways |
| **Security Groups** | Fine-grained network access control |

### ☸️ Compute Layer

| Component | Description |
|-----------|-------------|
| **EKS Control Plane** | Managed Kubernetes control plane by AWS |
| **Node Groups** | Self-managed or managed groups of worker nodes |
| **Auto Scaling** | Dynamic scaling based on workload demands |

### 🔐 Identity & Access Management

| Component | Description |
|-----------|-------------|
| **IAM Roles** | Least-privilege roles for EKS components |
| **OIDC Provider** | Integration for pod identity and service accounts |
| **Security Policies** | Proper permissions for cluster operations |

### 🧩 Add-ons & Extensions

| Component | Description |
|-----------|-------------|
| **Core Add-ons** | CoreDNS, kube-proxy, VPC CNI |
| **Optional Add-ons** | Support for additional functionality |

---

## 📦 Module Structure

<div align="center">
  <img src="https://via.placeholder.com/800x200?text=Module+Structure" alt="Module Structure" width="800">
</div>

The project is organized into reusable modules:

### 🌐 VPC Module

Creates and manages all networking components including VPC, subnets, internet gateways, NAT gateways, route tables, and security groups.

**Key Features:**
- Support for multiple VPCs using `for_each`
- Public and private subnet configuration
- NAT gateways for private subnet connectivity
- Security groups with dynamic rules

### ☸️ EKS Cluster Module

Provisions and manages the EKS control plane with comprehensive configuration options.

**Key Features:**
- OIDC provider integration for pod identity
- Support for multiple clusters
- Add-on management
- Advanced networking options

### 🔐 IAM Role Module

Creates IAM roles and policies with proper permissions for EKS components.

**Key Features:**
- Custom policy creation
- AWS managed policy attachment
- Dynamic policy document generation

### 🖥️ Node Group Module

Manages EKS node groups for worker nodes.

**Key Features:**
- Multiple node group support
- Customizable instance types
- Auto-scaling configuration
- Taints and labels support

---

## 🔄 Deployment Workflow

<div align="center">
  <img src="https://via.placeholder.com/800x200?text=Deployment+Workflow" alt="Deployment Workflow" width="800">
</div>

The infrastructure deployment follows this workflow:

1. **VPC Creation** → Sets up the networking foundation
   - VPC with custom CIDR block
   - Public and private subnets across availability zones
   - Internet Gateway and NAT Gateways
   - Route tables and security groups

2. **IAM Role Creation** → Establishes necessary permissions
   - EKS cluster role
   - Node instance role
   - Service account roles

3. **EKS Cluster Deployment** → Creates the Kubernetes control plane
   - EKS cluster with specified version
   - OIDC provider for pod identity
   - Cluster endpoint access configuration

4. **Node Group Provisioning** → Adds worker nodes to the cluster
   - Managed node groups with specified instance types
   - Auto-scaling configuration
   - Node labels and taints

5. **Add-on Installation** → Configures essential cluster add-ons
   - CoreDNS for DNS resolution
   - kube-proxy for network proxy
   - VPC CNI for pod networking

---

## ⚙️ Configuration Options

### 🌐 VPC Configuration

```hcl
vpcs = {
  main = {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
      Environment = "Production"
    }
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

### ☸️ EKS Cluster Configuration

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
    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
    tags = {
      Environment = "Production"
    }
  }
}
```

### 🖥️ Node Group Configuration

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
    disk_size      = 50
    
    labels = {
      "role" = "standard"
      "environment" = "production"
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
```

---

## 🏆 Best Practices Implemented

<div align="center">
  <img src="https://via.placeholder.com/800x200?text=Best+Practices" alt="Best Practices" width="800">
</div>

### 📝 Infrastructure as Code

- **Modular Design**: Each component is in its own module for reusability
- **DRY Principle**: Avoid repetition through variables and locals
- **Version Control**: All infrastructure code is version controlled
- **Consistent Formatting**: Code follows Terraform style conventions

### 🔒 Security

- **Least Privilege**: IAM roles follow principle of least privilege
- **Network Isolation**: Worker nodes in private subnets
- **API Server Access**: Restricted access to EKS API server
- **Security Groups**: Fine-grained network access control
- **Encryption**: Support for envelope encryption of Kubernetes secrets

### 🔄 High Availability

- **Multi-AZ Deployment**: Resources across multiple availability zones
- **Redundant NAT Gateways**: One per AZ for high availability
- **Auto Scaling**: Dynamic scaling based on workload demands

### 💰 Cost Optimization

- **Spot Instances**: Support for Spot instances for non-critical workloads
- **Right Sizing**: Configurable instance types for optimal resource usage
- **Auto Scaling**: Scale down during periods of low demand

### 🛠️ Operational Excellence

- **Logging**: EKS control plane logging for observability
- **Add-on Management**: Managed add-ons for easier updates
- **Documentation**: Comprehensive documentation for all modules

---

## 📊 Outputs and Integration

The project provides various outputs for integration with other systems:

```hcl
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "IDs of all subnets"
  value       = module.vpc.subnet_ids
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks-cluster.eks_clusters["test"].name
}

output "role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  value       = module.eks-cluster.eks_clusters["test"].arn
}

output "security_group_ids" {
  description = "IDs of security groups for the EKS cluster"
  value       = module.vpc.security_group_id
}
```

---

## 🚀 Future Enhancements

<div align="center">
  <img src="https://via.placeholder.com/800x200?text=Future+Enhancements" alt="Future Enhancements" width="800">
</div>

Planned enhancements for this project include:

1. **Helm Chart Deployment**: Infrastructure for deploying applications via Helm
2. **Monitoring Stack**: Integration with Prometheus and Grafana
3. **CI/CD Pipeline**: Automated testing and deployment of infrastructure changes
4. **Multi-Region Support**: Deployment across multiple AWS regions
5. **Backup and Disaster Recovery**: EKS backup solutions
6. **Service Mesh**: Integration with Istio or AWS App Mesh

---

## 🎯 Conclusion

<div align="center">
  <img src="https://via.placeholder.com/800x200?text=Conclusion" alt="Conclusion" width="800">
</div>

This Terraform EKS project provides a robust foundation for deploying and managing Kubernetes clusters on AWS. Its modular design, comprehensive configuration options, and adherence to best practices make it suitable for production environments of various sizes and requirements.

> *"Kubernetes made simple with Terraform"*

---

<div align="center">
  <p>Built with ❤️ for the Kubernetes community</p>
</div>
