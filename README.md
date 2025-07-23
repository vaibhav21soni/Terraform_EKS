# 🚀 AWS EKS Terraform Infrastructure

<div align="center">
  <br>
  <br>
  
  ![AWS EKS](https://img.shields.io/badge/AWS_EKS-Terraform-orange?style=for-the-badge)
  ![Terraform](https://img.shields.io/badge/Terraform-1.0+-blue?style=for-the-badge)
  ![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
</div>

<p align="center">
  <i>A production-ready Terraform solution for deploying and managing Amazon EKS clusters with advanced networking, security, and scalability features.</i>
</p>

---

## 🌟 Features at a Glance

- **🧩 Modular Design** - Reusable components for maximum flexibility
- **🔒 Security-First Approach** - Following AWS best practices
- **🌐 Multi-AZ Architecture** - For high availability and resilience
- **⚖️ Auto-scaling Capabilities** - Adapt to changing workloads
- **🛠️ Customizable Configuration** - Tailor to your specific needs
- **📊 Comprehensive Outputs** - For easy integration with other systems

---

## 📋 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Prerequisites](#-prerequisites)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Module Documentation](#-module-documentation)
- [Workflow](#-workflow)
- [Customization](#-customization)
- [Best Practices](#-best-practices)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🏗️ Architecture Overview


This project implements a production-grade EKS infrastructure with the following components:

| Component | Description |
|-----------|-------------|
| **VPC & Networking** | Custom VPC with public and private subnets across multiple AZs |
| **EKS Cluster** | Managed Kubernetes control plane with OIDC integration |
| **Node Groups** | Managed worker nodes with customizable instance types and scaling options |
| **IAM** | Least-privilege IAM roles and policies for cluster components |
| **Add-ons** | Support for essential EKS add-ons (CoreDNS, kube-proxy, VPC CNI, etc.) |

---

## 🔧 Prerequisites

Before you begin, ensure you have the following tools installed:

- **Terraform** v1.0+ - [Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- **AWS CLI** v2.0+ - [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- **kubectl** - [Installation Guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

You'll also need:
- AWS account with appropriate permissions
- AWS credentials configured locally

---

## 📁 Project Structure

```
terraform_eks/
├── 📄 data.tf                 # Data sources for EKS cluster
├── 📄 main.tf                 # Main module instantiation
├── 📄 output.tf               # Output values
├── 📄 provider.tf             # Provider configuration
├── 📄 variables.tf            # Input variables
├── 📂 modules/                # Reusable modules
│   ├── 📂 eks-cluster/        # EKS cluster configuration
│   ├── 📂 iam_role/           # IAM roles and policies
│   ├── 📂 node_group/         # EKS node groups
│   └── 📂 vpc/                # VPC and networking
└── 📄 README.md               # Project documentation
```

---

## 🚀 Getting Started

### ⚙️ Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/vaibhav21soni/terraform_eks.git
   cd terraform_eks
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Create a `terraform.tfvars` file with your configuration:**
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
   ```

4. **Plan the deployment:**
   ```bash
   terraform plan -out=tfplan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply tfplan
   ```

### 🔌 Accessing the Cluster

After deployment, configure kubectl to access your cluster:

```bash
aws eks update-kubeconfig --name <cluster-name> --region <region>
kubectl get nodes
```

---

## 📚 Module Documentation

Each module in this project has its own README.md file with detailed documentation:

<div align="center">

| Module | Description |
|--------|-------------|
| [EKS Cluster Module](./modules/eks-cluster/README.md) | Provisions and manages EKS clusters |
| [IAM Role Module](./modules/iam_role/README.md) | Creates IAM roles and policies |
| [Node Group Module](./modules/node_group/README.md) | Manages EKS node groups |
| [VPC Module](./modules/vpc/README.md) | Creates networking infrastructure |

</div>

---

## 🔄 Workflow


The infrastructure deployment follows this workflow:

1. **VPC Creation** → Sets up the networking foundation
2. **IAM Role Creation** → Establishes necessary permissions
3. **EKS Cluster Deployment** → Creates the Kubernetes control plane
4. **Node Group Provisioning** → Adds worker nodes to the cluster
5. **Add-on Installation** → Configures essential cluster add-ons

---

## 🛠️ Customization

### 🌐 VPC Configuration

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
  }
}
```

---

## 🏆 Best Practices

<div align="center">

| Category | Best Practices |
|----------|---------------|
| **Infrastructure as Code** | Modular design, DRY principle, version control |
| **Security** | Least privilege IAM, private subnets, restricted API access |
| **High Availability** | Multi-AZ deployment, redundant NAT gateways |
| **Cost Optimization** | Spot instances, right sizing, auto-scaling |
| **Operational Excellence** | Logging, managed add-ons, comprehensive documentation |

</div>

### 🔒 Security Best Practices

- Use private subnets for worker nodes
- Restrict EKS API server access with `public_access_cidrs`
- Implement least privilege IAM roles
- Enable EKS control plane logging
- Use security groups to restrict network traffic
- Enable envelope encryption for EKS secrets

### 💰 Cost Optimization

- Use Spot instances for non-critical workloads
- Implement proper auto-scaling configurations
- Right-size your node instances
- Use managed node groups to reduce operational overhead
- Clean up unused resources

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

<div align="center">
  <p>Built with ❤️ for the Kubernetes community</p>
</div>
