data "aws_iam_policy_document" "iam_policy_document" {
  for_each = var.iam_policy_definitions

  dynamic "statement" {
    for_each = each.value.statements
    content {
      sid       = lookup(statement.value, "sid", null)
      effect    = lookup(statement.value, "effect", "Allow")
      actions   = statement.value.actions
      resources = statement.value.resources

      dynamic "principals" {
        for_each = coalesce(try(statement.value.principals, null), [])
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = coalesce(try(statement.value.conditions, null), {})
        content {
          test     = condition.key
          variable = keys(condition.value)[0]
          values   = [condition.value[keys(condition.value)[0]]]
        }
      }
    }
  }
}

# IAM Policies (create actual policies with ARNs)
resource "aws_iam_policy" "iam_policy" {
  for_each = var.iam_policy_definitions

  name        = each.key
  description = lookup(each.value, "description", "Policy created by Terraform")
  policy      = data.aws_iam_policy_document.IAM_policy_document[each.key].json

  tags = merge(
    {
      Name = each.key
    },
    lookup(each.value, "tags", {})
  )
}

# IAM Roles
resource "aws_iam_role" "iam_roles" {
  for_each = var.iam_roles

  name = each.value.name

  assume_role_policy = try(
    each.value.assume_role_policy,
    data.aws_iam_policy_document.iam_policy_document[each.key].json
  )

  tags = merge(
    {
      Name = each.value.name
    },
    lookup(each.value, "tags", {})
  )
}

# Custom Policy Attachments (for policies created above)
resource "aws_iam_role_policy_attachment" "custom_policies" {
  for_each = var.iam_roles_attachments

  role       = aws_iam_role.iam_roles[each.value.role_key].name
  policy_arn = aws_iam_policy.iam_policy[each.value.policy_key].arn # Fix: Use aws_iam_policy, not data source
}

# AWS Managed Policy Attachments (for AWS managed policies)
resource "aws_iam_role_policy_attachment" "aws_managed_policies" {
  for_each = var.iam_roles_aws_managed_attachments != null ? var.iam_roles_aws_managed_attachments : {}

  role       = aws_iam_role.iam_roles[each.value.role_key].name
  policy_arn = each.value.policy_arn # Direct ARN for AWS managed policies
}