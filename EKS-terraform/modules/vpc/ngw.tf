
resource "aws_nat_gateway" "vpc_ngw" {
  for_each = var.nat_gateway_config

  allocation_id = aws_eip.eip_nat[each.value.eip_key].id
  subnet_id     = aws_subnet.subnets[each.value.subnet_key].id

  tags = {
    "Name" = "${var.project_name}-ngw-${each.key}"
  }
}
