output "output_iam_role_arns" {
  value = {
    for role_key, role in aws_iam_role.this :
    role_key => role.arn
  }
}


output "output_iam_role_names" {
  description = "All dynamic IAM role names"
  value = {
    for role_key, role in aws_iam_role.this :
    role_key => role.name
  }
}
output "output_iam_role_policies" {
  description = "All dynamic IAM role policies"
  value = {
    for role_key, role in aws_iam_role.this :
    role_key => {
      assume_role_policy = role.assume_role_policy
      tags               = role.tags
    }
  }
}