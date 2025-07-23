output "vpc_id" {
  value = { for k, vpc in aws_vpc.this : k => vpc.id }
}

output "eip_nat_ids" {
  description = "IDs of all allocated Elastic IPs for NAT Gateways"
  value       = { for k, eip in aws_eip.eip_nat : k => eip.id }
}

output "eip_nat_public_ips" {
  description = "Public IPs of Elastic IPs for NAT Gateways"
  value       = { for k, eip in aws_eip.eip_nat : k => eip.public_ip }
}

output "internet_gateway_id" {
  value = { for k, igw in aws_internet_gateway.vpc_igw : k => igw.id }
}

output "nat_gateway_ids" {
  description = "IDs of NAT Gateways"
  value       = { for k, ngw in aws_nat_gateway.vpc_ngw : k => ngw.id }
}

output "route_table_ids" {
  description = "IDs of all route tables"
  value       = { for k, rt in aws_route_table.route_tables : k => rt.id }
}

output "subnet_route_table_association_ids" {
  description = "IDs of route table associations for subnets"
  value       = { for k, assoc in aws_route_table_association.associations : k => assoc.id }
}

output "subnet_ids" {
  description = "IDs of all subnets"
  value       = { for k, subnet in aws_subnet.subnets : k => subnet.id }
}

output "security_group_id" {
  value = { for k, sg in aws_security_group.sg : k => sg.id }
}
