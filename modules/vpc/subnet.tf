resource "aws_subnet" "subnets" {
  for_each = var.subnets

  vpc_id                  = each.value.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public

  tags = merge(
    {
      Name = "${var.project_name}-${each.key}"
    },
    each.value.tags
  )
}
