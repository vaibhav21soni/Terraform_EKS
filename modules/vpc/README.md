# 🌐 VPC Module

<div align="center">
  <img src="https://d1.awsstatic.com/icons/console/manage/vpc.9c0e0d4c77b1be77a5a2b0b5695ee19a999b2aae.png" alt="VPC Logo" width="150" height="150">
  <br>
  <br>
  
  ![AWS VPC](https://img.shields.io/badge/AWS_VPC-Module-orange?style=for-the-badge)
  ![Terraform](https://img.shields.io/badge/Terraform-1.0+-blue?style=for-the-badge)
</div>

<p align="center">
  <i>A powerful Terraform module for creating and managing AWS networking infrastructure for your EKS cluster.</i>
</p>

---

## ✨ Features

- **🔄 Multiple VPCs** - Support for multiple VPCs using `for_each`
- **🌍 Multi-AZ Design** - Public and private subnets across availability zones
- **🌉 Internet Connectivity** - Internet Gateway for public subnet access
- **🔀 NAT Gateways** - Outbound internet access for private subnets
- **🛣️ Route Tables** - Flexible traffic management
- **🔒 Security Groups** - Dynamic ingress/egress rules
- **🔌 Elastic IPs** - Allocation for NAT Gateways

---

## 🚀 Usage

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  project_name = "my-eks-project"
  
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
  
  eips_config = {
    nat1 = {
      domain = "vpc"
    }
  }
  
  nat_gateway_config = {
    nat1 = {
      eip_key    = "nat1"
      subnet_key = "public1"
      tags = {
        Name = "main-nat-gateway"
      }
    }
  }
  
  security_groups = {
    eks_cluster_sg = {
      name        = "eks-cluster-sg"
      description = "Security group for EKS cluster"
      vpc_id      = module.vpc.vpc_id["main"]
      ingress = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/8"]
        }
      ]
      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }
  
  route_tables = {
    public = {
      vpc_id     = module.vpc.vpc_id["main"]
      name       = "public-route-table"
      gateway_id = module.vpc.internet_gateway_id["main"]
      cidr_block = "0.0.0.0/0"
      tags = {
        Name = "public-routes"
      }
    }
    private = {
      vpc_id     = module.vpc.vpc_id["main"]
      name       = "private-route-table"
      nat_id     = module.vpc.nat_gateway_ids["nat1"]
      cidr_block = "0.0.0.0/0"
      tags = {
        Name = "private-routes"
      }
    }
  }
  
  subnet_route_table_associations = {
    public1 = {
      subnet_key      = "public1"
      route_table_key = "public"
    }
    private1 = {
      subnet_key      = "private1"
      route_table_key = "private"
    }
  }
  
  vpc_igw = {
    main = {
      vpc_id = module.vpc.vpc_id["main"]
      tags = {
        Name = "main-igw"
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
| `vpcs` | Map of VPC configurations | `map(object)` | ✅ |
| `subnets` | Map of subnet configurations | `map(object)` | ✅ |
| `eips_config` | Map of Elastic IP configurations | `map(object)` | ✅ |
| `nat_gateway_config` | Map of NAT Gateway configurations | `map(object)` | ✅ |
| `security_groups` | Map of security group configurations | `map(object)` | ✅ |
| `route_tables` | Map of route table configurations | `map(object)` | ✅ |
| `subnet_route_table_associations` | Map of subnet to route table associations | `map(object)` | ✅ |
| `vpc_igw` | Map of Internet Gateway configurations | `map(object)` | ✅ |

</div>

---

## 📤 Outputs

<div align="center">

| Name | Description |
|------|-------------|
| `vpc_id` | Map of VPC IDs |
| `subnet_ids` | Map of subnet IDs |
| `internet_gateway_id` | Map of Internet Gateway IDs |
| `nat_gateway_ids` | Map of NAT Gateway IDs |
| `eip_nat_ids` | Map of Elastic IP IDs for NAT Gateways |
| `eip_nat_public_ips` | Map of Elastic IP public IPs for NAT Gateways |
| `route_table_ids` | Map of route table IDs |
| `subnet_route_table_association_ids` | Map of subnet route table association IDs |
| `security_group_id` | Map of security group IDs |

</div>

---

## 🏆 Best Practices

### 🏷️ Subnet Tagging

Always tag subnets properly for EKS integration:

```hcl
tags = {
  "kubernetes.io/role/elb" = "1"           # For public subnets
  "kubernetes.io/role/internal-elb" = "1"  # For private subnets
}
```

### 🔢 CIDR Planning

Plan your CIDR blocks carefully to avoid overlaps and allow for future expansion:

```hcl
cidr_block = "10.0.0.0/16"  # VPC CIDR
# Subnets
cidr_block = "10.0.1.0/24"  # Public subnet
cidr_block = "10.0.2.0/24"  # Private subnet
```

### 🌍 High Availability

Deploy resources across multiple availability zones for resilience:

```hcl
subnets = {
  public1 = {
    az = "us-west-2a"
    # ...
  }
  public2 = {
    az = "us-west-2b"
    # ...
  }
}
```

### 🔒 Security

Restrict security group rules to specific CIDR blocks rather than using `0.0.0.0/0`:

```hcl
ingress = [
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12"]  # Corporate network ranges
  }
]
```

### 💰 Cost Optimization

Be mindful of NAT Gateway costs - use one per AZ rather than one per subnet:

```hcl
nat_gateway_config = {
  nat1 = {
    eip_key    = "nat1"
    subnet_key = "public1"  # One NAT Gateway in AZ1
  }
  nat2 = {
    eip_key    = "nat2"
    subnet_key = "public2"  # One NAT Gateway in AZ2
  }
}
```

---

## 🧩 Network Architecture

<div align="center">
  <img src="https://via.placeholder.com/800x400?text=VPC+Architecture" alt="VPC Architecture" width="800">
</div>

### 🌐 VPC Design

The VPC is designed with the following components:

- **VPC**: Main network container with a large CIDR block
- **Public Subnets**: For internet-facing resources like NAT Gateways and load balancers
- **Private Subnets**: For internal resources like EKS worker nodes
- **Internet Gateway**: Provides internet connectivity for public subnets
- **NAT Gateways**: Enable outbound internet access from private subnets
- **Route Tables**: Control traffic flow between subnets and gateways
- **Security Groups**: Fine-grained network access control

### 🔀 Traffic Flow

1. **Inbound Traffic**:
   - Internet → Internet Gateway → Public Subnet → Load Balancer → Private Subnet → EKS Nodes

2. **Outbound Traffic**:
   - Private Subnet → NAT Gateway → Internet Gateway → Internet

---

<div align="center">
  <p>Built with ❤️ for secure and scalable networking</p>
</div>
