variable "karpenter_chart_version" {
  type        = string
  description = "Version of the Karpenter Helm chart to install"
}

variable "iam_roles" {
  description = "Map of IAM roles to create with their properties"
  type = map(object({
    name    = string
    service = string
    tags    = optional(map(string))
  }))
}



variable "iam_roles_attachments" {
  description = "Map of AWS managed policy attachments to IAM roles"
  type = map(object({
    role_key   = string
    policy_arn = string
  }))
}
