variable "project_name" {
  type = string
  #default = "demo"
}

variable "eks_oidc_providers" {
  description = "Map of EKS clusters for OIDC provider creation"
  type = map(object({
    cluster_name    = string
    client_id_list  = optional(list(string), ["sts.amazonaws.com"])
    thumbprint_list = optional(list(string))
    tags            = optional(map(string), {})

    # Optional: Reference to existing EKS cluster resource
    eks_cluster_reference = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for provider_key, provider in var.eks_oidc_providers :
      length(provider.cluster_name) > 0
    ])
    error_message = "EKS cluster name must not be empty."
  }
}



variable "eks_clusters" {
  description = "Map of EKS cluster configurations"
  type = map(object({
    # Required arguments
    name     = string
    role_arn = string
    vpc_config = object({
      subnet_ids              = list(string)
      endpoint_private_access = optional(bool, false)
      endpoint_public_access  = optional(bool, true)
      public_access_cidrs     = optional(list(string))
      security_group_ids      = optional(list(string))
    })

    # Optional arguments
    region                        = optional(string)
    bootstrap_self_managed_addons = optional(bool, true)
    enabled_cluster_log_types     = optional(list(string))
    force_update_version          = optional(bool, false)
    version                       = optional(string)
    tags                          = optional(map(string), {})

    # Access Config
    access_config = optional(object({
      authentication_mode                         = optional(string, "CONFIG_MAP")
      bootstrap_cluster_creator_admin_permissions = optional(bool, false)
    }))

    # Compute Config (EKS Auto Mode)
    compute_config = optional(object({
      enabled       = optional(bool, false)
      node_pools    = optional(list(string))
      node_role_arn = optional(string)
    }))

    # Encryption Config
    encryption_config = optional(object({
      provider = object({
        key_arn = string
      })
      resources = list(string)
    }))

    # Kubernetes Network Config
    kubernetes_network_config = optional(object({
      service_ipv4_cidr = optional(string)
      ip_family         = optional(string, "ipv4")
      elastic_load_balancing = optional(object({
        enabled = optional(bool, false)
      }))
    }))

    # Outpost Config
    outpost_config = optional(object({
      control_plane_instance_type = string
      outpost_arns                = list(string)
      control_plane_placement = optional(object({
        group_name = string
      }))
    }))

    # Remote Network Config (EKS Hybrid Nodes)
    remote_network_config = optional(object({
      remote_node_networks = optional(object({
        cidrs = list(string)
      }))
      remote_pod_networks = optional(object({
        cidrs = list(string)
      }))
    }))

    # Storage Config (EKS Auto Mode)
    storage_config = optional(object({
      block_storage = optional(object({
        enabled = optional(bool, false)
      }))
    }))

    # Upgrade Policy
    upgrade_policy = optional(object({
      support_type = optional(string, "STANDARD")
    }))

    # Zonal Shift Config
    zonal_shift_config = optional(object({
      enabled = optional(bool, false)
    }))

    # Dependencies
    depends_on_resources = optional(list(string), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for cluster_key, cluster in var.eks_clusters :
      can(regex("^[0-9A-Za-z][A-Za-z0-9\\-_]*$", cluster.name)) &&
      length(cluster.name) >= 1 && length(cluster.name) <= 100
    ])
    error_message = "EKS cluster name must be between 1-100 characters, begin with alphanumeric character, and contain only alphanumeric characters, dashes, and underscores."
  }

  validation {
    condition = alltrue([
      for cluster_key, cluster in var.eks_clusters :
      cluster.access_config != null ? contains(["CONFIG_MAP", "API", "API_AND_CONFIG_MAP"], cluster.access_config.authentication_mode) : true
    ])
    error_message = "Authentication mode must be one of: CONFIG_MAP, API, API_AND_CONFIG_MAP."
  }

  validation {
    condition = alltrue([
      for cluster_key, cluster in var.eks_clusters :
      cluster.kubernetes_network_config != null ? contains(["ipv4", "ipv6"], cluster.kubernetes_network_config.ip_family) : true
    ])
    error_message = "IP family must be either 'ipv4' or 'ipv6'."
  }

  validation {
    condition = alltrue([
      for cluster_key, cluster in var.eks_clusters :
      cluster.upgrade_policy != null ? contains(["EXTENDED", "STANDARD"], cluster.upgrade_policy.support_type) : true
    ])
    error_message = "Support type must be either 'EXTENDED' or 'STANDARD'."
  }
}

variable "eks_addons" {
  description = "Map of EKS addons to install"
  type = map(object({
    cluster_name                = string
    addon_version               = optional(string, null)
    addon_name                  = string
    resolve_conflicts           = optional(string, "OVERWRITE")
    name                        = optional(string, null)
    configuration_values        = optional(any, null)
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "PRESERVE")
    preserve                    = optional(bool, false)
    service_account_role_arn    = optional(string, null)
    pod_identity_association = optional(object({
      role_arn        = string
      service_account = string
    }), null)
    tags = optional(map(string), {})
  }))
}


