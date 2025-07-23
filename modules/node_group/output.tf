output "node_pools" {
    value = {
        for key, node_group in aws_eks_node_group.node_pools :
        key => {
        cluster_name  = node_group.cluster_name
        node_role_arn = node_group.node_role_arn
        subnet_ids    = node_group.subnet_ids
        scaling_config = {
            desired_size = node_group.scaling_config[0].desired_size
            max_size     = node_group.scaling_config[0].max_size
            min_size     = node_group.scaling_config[0].min_size
        }
        instance_types         = node_group.instance_types
        capacity_type          = node_group.capacity_type
        disk_size              = node_group.disk_size
        ami_type               = node_group.ami_type
        labels                 = node_group.labels
        version                = node_group.version
        node_group_name        = node_group.node_group_name
        node_group_name_prefix = node_group.node_group_name_prefix
        tags                   = node_group.tags
    
        taint = [
            for taint in node_group.taint : {
            key    = taint.key
            value  = taint.value
            effect = taint.effect
            }
        ]
    
        update_config = {
            max_unavailable            = lookup(node_group.update_config[0], "max_unavailable", null)
            max_unavailable_percentage = lookup(node_group.update_config[0], "max_unavailable_percentage", null)
        }
        }
    }
  
}