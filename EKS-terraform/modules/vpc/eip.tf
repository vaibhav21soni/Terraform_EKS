
resource "aws_eip" "eip_nat" {
  for_each = var.eips_config

  domain = each.value.domain
  tags = {
    Name = "${var.project_name}-nat-eip-${each.key}"

  }
}


