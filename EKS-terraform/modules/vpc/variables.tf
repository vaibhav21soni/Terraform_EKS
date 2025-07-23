variable "vpcs" {
  description = "Map of VPC configurations"
  type = map(object({
    cidr_block                           = optional(string)
    instance_tenancy                     = optional(string)
    ipv4_ipam_pool_id                    = optional(string)
    ipv4_netmask_length                  = optional(number)
    ipv6_cidr_block                      = optional(string)
    ipv6_ipam_pool_id                    = optional(string)
    ipv6_netmask_length                  = optional(number)
    ipv6_cidr_block_network_border_group = optional(string)
    enable_dns_support                   = optional(bool)
    enable_dns_hostnames                 = optional(bool)
    enable_network_address_usage_metrics = optional(bool)
    assign_generated_ipv6_cidr_block     = optional(bool)
    tags                                 = optional(map(string))
  }))
}


variable "nat_gateway_config" {
  description = "Map of NAT Gateway config by AZ"
  type = map(object({
    eip_key    = string
    subnet_key = string
  }))
}

variable "eips_config" {
  description = "Map of EIPs with interface and private IP"
  type = map(object({
    domain = string
  }))
}

variable "subnets" {
  description = "Map of subnets with config and optional tags"
  type = map(object({
    vpc_id     = optional(string)
    az         = string
    cidr_block = string
    public     = bool
    tags       = optional(map(string), {})
  }))
}

variable "security_groups" {
  type = map(object({
    name        = string
    description = optional(string)
    vpc_id      = optional(string)
    ingress = optional(list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string))
      security_groups = optional(list(string))
      self            = optional(bool)
    })))
    egress = optional(list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string))
      security_groups = optional(list(string))
      self            = optional(bool)
    })))
    tags = optional(map(string))
  }))
}

variable "route_tables" {
  description = "Map of route tables with their configuration"
  type = map(object({
    vpc_id     = string
    cidr_block = optional(string)
    # Only one of these should be set
    # gateway_id for IGW, nat_id for NAT Gateway
    # If both are set, gateway_id will be used
    # and nat_id will be ignored
    name       = string
    gateway_id = optional(string)
    nat_id     = optional(string)
    tags       = optional(map(string))
  }))
}
variable "subnet_route_table_associations" {
  description = "Map of subnet to route table associations"
  type = map(object({
    subnet_key      = string
    route_table_key = string
  }))
}
variable "project_name" {
  type        = string
  description = "Name of the project for tagging resources"
}
variable "vpc_igw" {
  description = "Map of VPC Internet Gateways"
  type = map(object({
    vpc_id = string
    tags   = optional(map(string), {})

  }))

}