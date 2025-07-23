resource "aws_eks_cluster" "clusters" {
  for_each = var.eks_clusters

  # Required arguments
  name     = each.value.name
  role_arn = each.value.role_arn

  vpc_config {
    subnet_ids              = each.value.vpc_config.subnet_ids
    endpoint_private_access = each.value.vpc_config.endpoint_private_access
    endpoint_public_access  = each.value.vpc_config.endpoint_public_access
    public_access_cidrs     = each.value.vpc_config.public_access_cidrs
    security_group_ids      = each.value.vpc_config.security_group_ids
  }

  # Optional arguments
  bootstrap_self_managed_addons = each.value.bootstrap_self_managed_addons
  enabled_cluster_log_types     = each.value.enabled_cluster_log_types
  force_update_version          = each.value.force_update_version
  version                       = each.value.version
  tags                          = each.value.tags

  # Access Config
  dynamic "access_config" {
    for_each = each.value.access_config != null ? [each.value.access_config] : []
    content {
      authentication_mode                         = access_config.value.authentication_mode
      bootstrap_cluster_creator_admin_permissions = access_config.value.bootstrap_cluster_creator_admin_permissions
    }
  }

  # Compute Config
  dynamic "compute_config" {
    for_each = each.value.compute_config != null ? [each.value.compute_config] : []
    content {
      enabled       = compute_config.value.enabled
      node_pools    = compute_config.value.node_pools
      node_role_arn = compute_config.value.node_role_arn
    }
  }

  # Encryption Config
  dynamic "encryption_config" {
    for_each = each.value.encryption_config != null ? [each.value.encryption_config] : []
    content {
      provider {
        key_arn = encryption_config.value.provider.key_arn
      }
      resources = encryption_config.value.resources
    }
  }

  # Kubernetes Network Config
  dynamic "kubernetes_network_config" {
    for_each = each.value.kubernetes_network_config != null ? [each.value.kubernetes_network_config] : []
    content {
      service_ipv4_cidr = kubernetes_network_config.value.service_ipv4_cidr
      ip_family         = kubernetes_network_config.value.ip_family

      dynamic "elastic_load_balancing" {
        for_each = kubernetes_network_config.value.elastic_load_balancing != null ? [kubernetes_network_config.value.elastic_load_balancing] : []
        content {
          enabled = elastic_load_balancing.value.enabled
        }
      }
    }
  }

  # Outpost Config
  dynamic "outpost_config" {
    for_each = each.value.outpost_config != null ? [each.value.outpost_config] : []
    content {
      control_plane_instance_type = outpost_config.value.control_plane_instance_type
      outpost_arns                = outpost_config.value.outpost_arns

      dynamic "control_plane_placement" {
        for_each = outpost_config.value.control_plane_placement != null ? [outpost_config.value.control_plane_placement] : []
        content {
          group_name = control_plane_placement.value.group_name
        }
      }
    }
  }

  # Remote Network Config
  dynamic "remote_network_config" {
    for_each = each.value.remote_network_config != null ? [each.value.remote_network_config] : []
    content {
      dynamic "remote_node_networks" {
        for_each = remote_network_config.value.remote_node_networks != null ? [remote_network_config.value.remote_node_networks] : []
        content {
          cidrs = remote_node_networks.value.cidrs
        }
      }

      dynamic "remote_pod_networks" {
        for_each = remote_network_config.value.remote_pod_networks != null ? [remote_network_config.value.remote_pod_networks] : []
        content {
          cidrs = remote_pod_networks.value.cidrs
        }
      }
    }
  }

  # Storage Config
  dynamic "storage_config" {
    for_each = each.value.storage_config != null ? [each.value.storage_config] : []
    content {
      dynamic "block_storage" {
        for_each = storage_config.value.block_storage != null ? [storage_config.value.block_storage] : []
        content {
          enabled = block_storage.value.enabled
        }
      }
    }
  }

  # Upgrade Policy
  dynamic "upgrade_policy" {
    for_each = each.value.upgrade_policy != null ? [each.value.upgrade_policy] : []
    content {
      support_type = upgrade_policy.value.support_type
    }
  }

  # Zonal Shift Config
  dynamic "zonal_shift_config" {
    for_each = each.value.zonal_shift_config != null ? [each.value.zonal_shift_config] : []
    content {
      enabled = zonal_shift_config.value.enabled
    }
  }
}



