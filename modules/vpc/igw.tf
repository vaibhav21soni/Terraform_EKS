resource "aws_internet_gateway" "vpc_igw" {
  for_each = var.vpc_igw
  vpc_id   = each.value.vpc_id
  tags = merge(each.value.tags, {
    Name = "${var.project_name}-igw-${each.key}"
  })
}