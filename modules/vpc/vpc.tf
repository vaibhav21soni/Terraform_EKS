resource "aws_vpc" "vpcs" {
  for_each = var.vpcs

  cidr_block                           = lookup(each.value, "cidr_block", null)
  instance_tenancy                     = lookup(each.value, "instance_tenancy", "default")
  ipv4_ipam_pool_id                    = lookup(each.value, "ipv4_ipam_pool_id", null)
  ipv4_netmask_length                  = lookup(each.value, "ipv4_netmask_length", null)
  ipv6_cidr_block                      = lookup(each.value, "ipv6_cidr_block", null)
  ipv6_ipam_pool_id                    = lookup(each.value, "ipv6_ipam_pool_id", null)
  ipv6_netmask_length                  = lookup(each.value, "ipv6_netmask_length", null)
  ipv6_cidr_block_network_border_group = lookup(each.value, "ipv6_cidr_block_network_border_group", null)

  enable_dns_support                   = lookup(each.value, "enable_dns_support", true)
  enable_dns_hostnames                 = lookup(each.value, "enable_dns_hostnames", false)
  enable_network_address_usage_metrics = lookup(each.value, "enable_network_address_usage_metrics", false)
  assign_generated_ipv6_cidr_block     = lookup(each.value, "assign_generated_ipv6_cidr_block", false)

  tags = merge(
    {
      Name = lookup(each.value, "name", "vpc-${each.key}")
    },
  lookup(each.value, "tags", {}))
}
