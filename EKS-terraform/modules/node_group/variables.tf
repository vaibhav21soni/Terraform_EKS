variable "eks_node_groups" {
  description = "Map of EKS node group configurations"
  type = map(object({
    cluster_name  = string
    node_role_arn = string
    subnet_ids    = list(string)
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
    instance_types         = optional(list(string))
    capacity_type          = optional(string)
    disk_size              = optional(number)
    ami_type               = optional(string)
    labels                 = optional(map(string))
    version                = optional(string)
    node_group_name        = optional(string)
    node_group_name_prefix = optional(string)
    tags                   = optional(map(string))
    taint = optional(list(object({
      key    = string
      value  = optional(string)
      effect = string
    })))
    update_config = optional(object({
      max_unavailable            = optional(number)
      max_unavailable_percentage = optional(number)
    }))
  }))
}
