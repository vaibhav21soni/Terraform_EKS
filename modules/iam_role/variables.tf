# modules/iam_role/variables.tf

variable "iam_policy_definitions" {
  description = "Map of policy definitions"
  type = map(object({
    description = optional(string)
    statements = list(object({
      sid       = optional(string)
      effect    = optional(string)
      actions   = list(string)
      resources = list(string)
      principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })))
      conditions = optional(map(map(string)))
    }))
    tags = optional(map(string))
  }))
  default = {}
}

variable "iam_roles" {
  description = "Map of IAM roles"
  type = map(object({
    name               = string
    assume_role_policy = optional(string)
    tags               = optional(map(string))
  }))
}

variable "iam_roles_attachments" {
  description = "Map of role to custom policy attachments"
  type = map(object({
    role_key   = string
    policy_key = string
  }))
  default = {}
}

variable "iam_roles_aws_managed_attachments" {
  description = "Map of role to AWS managed policy attachments"
  type = map(object({
    role_key   = string
    policy_arn = string
  }))
  default = {}
}