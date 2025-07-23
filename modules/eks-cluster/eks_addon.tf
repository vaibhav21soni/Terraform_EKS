
resource "aws_eks_addon" "eks_addons" {
  for_each                    = var.eks_addons
  cluster_name                = each.value.cluster_name
  addon_name                  = each.key
  addon_version               = each.value.addon_version
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update
  preserve                    = each.value.preserve
  service_account_role_arn    = each.value.service_account_role_arn

  configuration_values = each.value.configuration_values != null ? jsonencode(each.value.configuration_values) : null

  # Pod Identity Association block
  dynamic "pod_identity_association" {
    for_each = each.value.pod_identity_association != null ? [each.value.pod_identity_association] : []
    content {
      role_arn        = pod_identity_association.value.role_arn
      service_account = pod_identity_association.value.service_account
    }
  }

  tags = merge(
    {
      Name    = "${aws_eks_cluster.clusters[each.key].name}-${each.key}"
      Addon   = each.key
      Cluster = aws_eks_cluster.clusters[each.key].name
    },
    each.value.tags
  )
}