# VPC Module

This module creates a complete AWS networking stack for your EKS cluster, including VPC, subnets, internet gateways, NAT gateways, route tables, and security groups.

## Features

- Support for multiple VPCs using `for_each`
- Public and private subnet configuration across availability zones
- Internet Gateway for public subnet connectivity
- NAT Gateways for private subnet outbound access
- Route tables with proper associations
- Security groups with dynamic ingress/egress rules
- Elastic IP allocation for NAT Gateways

## Usage

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

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| `project_name` | Name of the project for resource naming and tagging | `string` | yes |
| `vpcs` | Map of VPC configurations | `map(object)` | yes |
| `subnets` | Map of subnet configurations | `map(object)` | yes |
| `eips_config` | Map of Elastic IP configurations | `map(object)` | yes |
| `nat_gateway_config` | Map of NAT Gateway configurations | `map(object)` | yes |
| `security_groups` | Map of security group configurations | `map(object)` | yes |
| `route_tables` | Map of route table configurations | `map(object)` | yes |
| `subnet_route_table_associations` | Map of subnet to route table associations | `map(object)` | yes |
| `vpc_igw` | Map of Internet Gateway configurations | `map(object)` | yes |

## Outputs

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

## Best Practices

1. **Subnet Tagging**: Always tag subnets properly for EKS integration:
   - Public subnets: `kubernetes.io/role/elb = 1`
   - Private subnets: `kubernetes.io/role/internal-elb = 1`

2. **CIDR Planning**: Plan your CIDR blocks carefully to avoid overlaps and allow for future expansion.

3. **High Availability**: Deploy resources across multiple availability zones for resilience.

4. **Security**: Restrict security group rules to specific CIDR blocks rather than using `0.0.0.0/0`.

5. **Cost Optimization**: Be mindful of NAT Gateway costs - use one per AZ rather than one per subnet.
