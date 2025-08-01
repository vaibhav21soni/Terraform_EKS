# 🚀 AWS EKS Terraform Infrastructure

<div align="center">
  <br>
  <br>
  
  ![AWS EKS](https://img.shields.io/badge/AWS_EKS-Terraform-orange?style=for-the-badge)
  ![Terraform](https://img.shields.io/badge/Terraform-1.0+-blue?style=for-the-badge)
  ![Rust](https://img.shields.io/badge/Rust-Compatible-red?style=for-the-badge)
  ![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
</div>

<p align="center">
  <i>A production-ready Terraform solution for deploying and managing Amazon EKS clusters with advanced networking, security, scalability features, and Rust application support.</i>
</p>

---

## 🌟 Features at a Glance

- **🧩 Modular Design** - Reusable components for maximum flexibility
- **🔒 Security-First Approach** - Following AWS best practices
- **🌐 Multi-AZ Architecture** - For high availability and resilience
- **⚖️ Auto-scaling Capabilities** - Adapt to changing workloads
- **🛠️ Customizable Configuration** - Tailor to your specific needs
- **📊 Comprehensive Outputs** - For easy integration with other systems
- **🏢 Workspace Support** - Multi-environment management
- **🦀 Rust-Ready** - Optimized for Rust application deployments
- **🔄 Dynamic Configuration** - No hardcoded values, fully parameterized

---

## 📋 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Prerequisites](#-prerequisites)
- [Project Structure](#-project-structure)
- [Quick Start](#-quick-start)
- [Backend Setup](#-backend-setup)
- [Workspace Management](#-workspace-management)
- [Configuration](#-configuration)
- [Module Documentation](#-module-documentation)
- [Rust Applications](#-rust-applications)
- [Best Practices](#-best-practices)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

---

## 🏗️ Architecture Overview

This project implements a production-grade EKS infrastructure with the following components:

| Component | Description | Features |
|-----------|-------------|----------|
| **VPC & Networking** | Custom VPC with public and private subnets across multiple AZs | Dynamic CIDR calculation, NAT Gateways, Route Tables |
| **EKS Cluster** | Managed Kubernetes control plane with OIDC integration | Encryption, Logging, Security Groups |
| **Node Groups** | Managed worker nodes with customizable instance types and scaling | Auto-scaling, Multiple instance types, Spot support |
| **IAM** | Least-privilege IAM roles and policies for cluster components | Custom policies, AWS managed policies |
| **Add-ons** | Essential EKS add-ons (CoreDNS, kube-proxy, VPC CNI, EBS CSI) | Version management, Conflict resolution |
| **Backend** | S3 state storage with DynamoDB locking | Workspace support, Encryption, Versioning |

---

## 🔧 Prerequisites

Before you begin, ensure you have the following tools installed:

- **Terraform** v1.0+ - [Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- **AWS CLI** v2.0+ - [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- **kubectl** - [Installation Guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

**For Rust Development:**
- **Rust** - [Installation Guide](https://rustup.rs/)
- **Docker** - [Installation Guide](https://docs.docker.com/get-docker/)

**AWS Requirements:**
- AWS account with appropriate permissions
- AWS credentials configured locally (`aws configure`)

---

## 📁 Project Structure

```
terraform_eks/
├── 📄 versions.tf             # Terraform and provider versions + backend
├── 📄 provider.tf             # Provider configurations with default tags
├── 📄 variables.tf            # Input variables with validation
├── 📄 locals.tf               # Local values and dynamic configuration
├── 📄 data.tf                 # Data sources for AWS resources
├── 📄 main.tf                 # Main module instantiation
├── 📄 output.tf               # Output values
├── 📄 terraform.tfvars.example # Example configuration file
├── 📄 setup-backend.sh        # Backend setup script
├── 📄 .gitignore              # Git ignore patterns
├── 📂 modules/                # Reusable modules
│   ├── 📂 eks-cluster/        # EKS cluster configuration
│   ├── 📂 iam_role/           # IAM roles and policies
│   ├── 📂 node_group/         # EKS node groups
│   └── 📂 vpc/                # VPC and networking
└── 📄 README.md               # This file
```

---

## 🚀 Quick Start

### 1. **Clone and Setup**
```bash
git clone https://github.com/vaibhav21soni/terraform_eks.git
cd terraform_eks
```

### 2. **Setup Backend Infrastructure**
```bash
# Make script executable and run
chmod +x setup-backend.sh
./setup-backend.sh
```

### 3. **Configure Variables**
```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

### 4. **Initialize and Deploy**
```bash
# Initialize Terraform
terraform init

# Create workspace (optional but recommended)
terraform workspace new dev

# Plan deployment
terraform plan -out=tfplan

# Apply configuration
terraform apply tfplan
```

### 5. **Configure kubectl**
```bash
# Get the kubectl command from output
terraform output kubectl_config_command

# Or manually configure
aws eks update-kubeconfig --region us-west-2 --name your-cluster-name
```

---

## 🗄️ Backend Setup

The project uses S3 backend with DynamoDB for state locking and workspace support.

### **Automatic Setup**
```bash
./setup-backend.sh
```

### **Manual Setup**
```bash
# Create S3 bucket
aws s3api create-bucket \
  --bucket terraform-state-eks-infrastructure \
  --region us-west-2 \
  --create-bucket-configuration LocationConstraint=us-west-2

# Create DynamoDB table
aws dynamodb create-table \
  --table-name terraform-locks-eks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

---

## 🏢 Workspace Management

Workspaces allow you to manage multiple environments with the same configuration:

```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new production
terraform workspace new staging
terraform workspace new dev

# Switch workspace
terraform workspace select dev

# Show current workspace
terraform workspace show
```

Each workspace maintains separate state files and can have different variable values.

---

## ⚙️ Configuration

### **Core Variables** (`terraform.tfvars`)

```hcl
# Project Configuration
project_name = "my-eks-project"
aws_region   = "us-west-2"
environment  = "dev"

# VPC Configuration
vpcs = {
  main = {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
  }
}

# EIP Configuration
eips_config = {
  nat1 = { domain = "vpc" }
  nat2 = { domain = "vpc" }
}

# Node Groups
node_groups = {
  main = {
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    scaling_config = {
      desired_size = 2
      max_size     = 4
      min_size     = 1
    }
  }
}
```

### **Advanced Configuration**

<details>
<summary>Click to expand advanced options</summary>

```hcl
# Security Configuration
enable_cluster_encryption = true
cluster_log_types = ["api", "audit", "authenticator"]
cluster_endpoint_public_access_cidrs = ["10.0.0.0/8"]

# Multiple Node Groups
node_groups = {
  general = {
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    scaling_config = {
      desired_size = 2
      max_size     = 5
      min_size     = 1
    }
  }
  spot = {
    instance_types = ["t3.large", "t3.xlarge"]
    capacity_type  = "SPOT"
    scaling_config = {
      desired_size = 1
      max_size     = 10
      min_size     = 0
    }
  }
}

# Custom Add-ons
cluster_addons = {
  coredns = {
    addon_version = "v1.10.1-eksbuild.5"
  }
  vpc-cni = {
    addon_version = "v1.15.1-eksbuild.1"
  }
  aws-ebs-csi-driver = {
    addon_version = "v1.24.0-eksbuild.1"
  }
}
```

</details>

---

## 📚 Module Documentation

Each module has comprehensive documentation:

| Module | Purpose | Key Features |
|--------|---------|--------------|
| [**VPC Module**](./modules/vpc/) | Networking infrastructure | Multi-AZ, NAT Gateways, Security Groups |
| [**IAM Role Module**](./modules/iam_role/) | Identity and access management | Least privilege, Custom policies |
| [**EKS Cluster Module**](./modules/eks-cluster/) | Kubernetes control plane | OIDC, Add-ons, Encryption |
| [**Node Group Module**](./modules/node_group/) | Worker nodes | Auto-scaling, Mixed instances |

---

## 🦀 Rust Applications

This EKS infrastructure is optimized for Rust applications:

### **Container Optimization**
```dockerfile
# Multi-stage Rust build
FROM rust:1.70 as builder
WORKDIR /app
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/myapp /usr/local/bin/myapp
CMD ["myapp"]
```

### **Kubernetes Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rust-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: rust-app
  template:
    metadata:
      labels:
        app: rust-app
    spec:
      containers:
      - name: rust-app
        image: your-registry/rust-app:latest
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
```

### **Debugging with RUST_BACKTRACE**
```bash
# Enable detailed backtraces
export RUST_BACKTRACE=1

# Or in Kubernetes
env:
- name: RUST_BACKTRACE
  value: "1"
```

---

## 🏆 Best Practices

### **Infrastructure**
- ✅ Use workspaces for environment separation
- ✅ Enable state locking with DynamoDB
- ✅ Use dynamic references instead of hardcoded values
- ✅ Implement proper tagging strategy
- ✅ Enable encryption for sensitive data

### **Security**
- ✅ Private subnets for worker nodes
- ✅ Restricted API server access
- ✅ Least privilege IAM roles
- ✅ Security groups with minimal access
- ✅ Enable cluster logging and monitoring

### **Cost Optimization**
- ✅ Use Spot instances for non-critical workloads
- ✅ Implement proper auto-scaling
- ✅ Right-size your instances
- ✅ Use managed node groups
- ✅ Monitor and optimize resource usage

### **Rust Applications**
- ✅ Use multi-stage Docker builds
- ✅ Optimize binary size with `strip` and `opt-level`
- ✅ Implement proper health checks
- ✅ Use structured logging (tracing crate)
- ✅ Enable metrics collection

---

## 🔍 Troubleshooting

### **Common Issues**

<details>
<summary>Backend initialization fails</summary>

```bash
# Ensure backend resources exist
./setup-backend.sh

# Check AWS credentials
aws sts get-caller-identity

# Verify bucket access
aws s3 ls s3://terraform-state-eks-infrastructure
```

</details>

<details>
<summary>Node groups fail to create</summary>

```bash
# Check IAM roles
aws iam get-role --role-name your-project-dev-eks-node-role

# Verify subnet tags
aws ec2 describe-subnets --filters "Name=tag:kubernetes.io/cluster/your-cluster,Values=owned"
```

</details>

<details>
<summary>kubectl access denied</summary>

```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name your-cluster-name

# Check AWS identity
aws sts get-caller-identity

# Verify cluster status
aws eks describe-cluster --name your-cluster-name
```

</details>

### **Useful Commands**

```bash
# Validate Terraform configuration
terraform validate

# Format Terraform files
terraform fmt -recursive

# Show current state
terraform show

# List resources
terraform state list

# Get specific output
terraform output cluster_endpoint
```

---

## 📊 Outputs

The configuration provides comprehensive outputs:

```bash
# Cluster information
terraform output cluster_name
terraform output cluster_endpoint
terraform output cluster_arn

# Network information
terraform output vpc_id
terraform output private_subnet_ids
terraform output public_subnet_ids

# Access information
terraform output kubectl_config_command
terraform output oidc_provider_arn
```

---

## 🔄 Workflow

The deployment follows this workflow:

1. **Backend Setup** → S3 bucket and DynamoDB table creation
2. **VPC Creation** → Networking foundation with dynamic CIDR calculation
3. **IAM Role Creation** → Security permissions with least privilege
4. **EKS Cluster Deployment** → Kubernetes control plane with add-ons
5. **Node Group Provisioning** → Worker nodes with auto-scaling
6. **Application Deployment** → Ready for Rust and other applications

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly (`terraform validate`, `terraform plan`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### **Development Setup**
```bash
# Install pre-commit hooks
pip install pre-commit
pre-commit install

# Run tests
terraform validate
terraform fmt -check
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🆘 Support

- 📖 [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- 📖 [Amazon EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- 📖 [Kubernetes Documentation](https://kubernetes.io/docs/)
- 📖 [Rust Documentation](https://doc.rust-lang.org/)
- 🐛 [Report Issues](https://github.com/vaibhav21soni/terraform_eks/issues)

---

<div align="center">
  <p>Built with ❤️ for the Kubernetes and Rust communities</p>
  <p>⭐ Star this repo if it helped you!</p>
</div>
