resource "aws_route_table" "route_tables" {
  for_each = var.route_tables

  vpc_id = each.value.vpc_id

  # Add route only if gateway_id or nat_id is present
  dynamic "route" {
    for_each = (
      each.value.gateway_id != null || each.value.nat_id != null
    ) ? [1] : []

    content {
      cidr_block = each.value.cidr_block

      # Only one of these should be set
      gateway_id     = each.value.gateway_id != null ? each.value.gateway_id : null
      nat_gateway_id = each.value.nat_id != null ? each.value.nat_id : null
    }
  }

  tags = merge(
    {
      Name = "${var.project_name}-${each.value.name}"
    },
    lookup(each.value, "tags", {})
  )
}



resource "aws_route_table_association" "associations" {
  for_each = var.subnet_route_table_associations

  subnet_id      = aws_subnet.subnets[each.value.subnet_key].id
  route_table_id = aws_route_table.route_tables[each.value.route_table_key].id
}


