resource "aws_security_group" "sg" {
  for_each = var.security_groups

  name        = each.key
  description = lookup(each.value, "description", "Security group ${each.key}")
  vpc_id      = lookup(each.value, "vpc_id", null)

  dynamic "ingress" {
    for_each = lookup(each.value, "ingress", [])
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = lookup(ingress.value, "security_groups", null)
      self            = lookup(ingress.value, "self", null)
    }
  }

  dynamic "egress" {
    for_each = lookup(each.value, "egress", [])
    content {
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = lookup(egress.value, "cidr_blocks", null)
      security_groups = lookup(egress.value, "security_groups", null)
      self            = lookup(egress.value, "self", null)
    }
  }

  tags = lookup(each.value, "tags", {})
}