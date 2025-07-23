resource "aws_eks_node_group" "node_pools" {
  for_each = var.eks_node_groups

  cluster_name  = each.value.cluster_name
  node_role_arn = each.value.node_role_arn
  subnet_ids    = each.value.subnet_ids

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  instance_types         = lookup(each.value, "instance_types", null)
  capacity_type          = lookup(each.value, "capacity_type", null)
  disk_size              = lookup(each.value, "disk_size", null)
  ami_type               = lookup(each.value, "ami_type", null)
  labels                 = lookup(each.value, "labels", null)
  version                = lookup(each.value, "version", null)
  node_group_name        = lookup(each.value, "node_group_name", null)
  node_group_name_prefix = lookup(each.value, "node_group_name_prefix", null)
  tags                   = lookup(each.value, "tags", null)

  dynamic "taint" {
    for_each = lookup(each.value, "taint", [])
    content {
      key    = taint.value.key
      value  = lookup(taint.value, "value", null)
      effect = taint.value.effect
    }
  }

  dynamic "update_config" {
    for_each = lookup(each.value, "update_config", []) != null ? [1] : []
    content {
      max_unavailable            = lookup(each.value.update_config, "max_unavailable", null)
      max_unavailable_percentage = lookup(each.value.update_config, "max_unavailable_percentage", null)
    }
  }
}
