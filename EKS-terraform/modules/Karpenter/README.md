# Karpenter Module

This module deploys and configures Karpenter, an open-source node provisioning project that improves the efficiency and cost of running workloads on Kubernetes.

## Features

- Helm chart deployment with configurable values
- IAM role creation with proper permissions
- Support for multiple Karpenter configurations
- Integration with EKS OIDC provider for pod identity
- Customizable settings for node provisioning

## Usage

```hcl
module "karpenter" {
  source = "./modules/Karpenter"
  
  karpenter_chart_version = "0.37.0"
  
  cluster_name           = module.eks-cluster.eks_clusters["main"].name
  oidc_provider_arn      = module.eks-cluster.eks_cluster_oidc_provider_arn["main"]
  oidc_issuer_url        = module.eks-cluster.eks_cluster_oidc_issuer_url["main"]
  node_instance_profile_name = "KarpenterNodeInstanceProfile"
  cluster_endpoint       = module.eks-cluster.eks_cluster_endpoint["main"]
  environment            = "production"
  
  karpenter_configs = {
    main = {
      name             = "karpenter"
      namespace        = "karpenter"
      chart            = "karpenter"
      repository       = "oci://public.ecr.aws/karpenter"
      version          = "0.37.0"
      create_namespace = true
      values           = [
        file("${path.module}/karpenter-values.yaml")
      ]
      additional_sets = [
        {
          name  = "controller.resources.requests.cpu"
          value = "1"
        },
        {
          name  = "controller.resources.requests.memory"
          value = "1Gi"
        }
      ]
    }
  }
  
  iam_roles = {
    karpenter_controller = {
      name    = "KarpenterController"
      service = "eks.amazonaws.com"
      tags    = {
        Purpose = "Karpenter Controller"
      }
    }
  }
  
  iam_roles_attachments = {
    karpenter_controller_policy = {
      role_key   = "karpenter_controller"
      policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    }
  }
  
  tags = {
    Project     = "EKS Infrastructure"
    Component   = "Karpenter"
    Environment = "Production"
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| `karpenter_chart_version` | Version of the Karpenter Helm chart to install | `string` | yes |
| `cluster_name` | EKS cluster name | `string` | yes |
| `oidc_provider_arn` | OIDC provider ARN for EKS cluster | `string` | yes |
| `oidc_issuer_url` | OIDC issuer URL for EKS cluster | `string` | yes |
| `node_instance_profile_name` | EC2 instance profile name for Karpenter nodes | `string` | yes |
| `cluster_endpoint` | EKS cluster endpoint | `string` | yes |
| `environment` | Environment name | `string` | no |
| `karpenter_configs` | Map of Karpenter configurations | `map(object)` | yes |
| `iam_roles` | Map of IAM roles to create | `map(object)` | yes |
| `iam_roles_attachments` | Map of AWS managed policy attachments to IAM roles | `map(object)` | yes |
| `tags` | Additional tags for resources | `map(string)` | no |

### karpenter_configs Object Structure

```hcl
{
  name             = string
  namespace        = string
  chart            = optional(string, "karpenter")
  repository       = optional(string, "oci://public.ecr.aws/karpenter")
  version          = optional(string, "0.37.0")
  create_namespace = optional(bool, true)
  values           = optional(list(string), [])
  additional_sets = optional(list(object({
    name  = string
    value = string
    type  = optional(string, "string")
  })), [])
}
```

## Outputs

| Name | Description |
|------|-------------|
| `karpenter_releases` | Helm release information for Karpenter deployments |
| `iam_roles` | IAM roles created for Karpenter controllers |

## Karpenter Provisioner Example

After deploying Karpenter, you'll need to create a Provisioner resource. Here's an example:

```yaml
# provisioner.yaml
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["spot", "on-demand"]
    - key: kubernetes.io/arch
      operator: In
      values: ["amd64"]
    - key: node.kubernetes.io/instance-type
      operator: In
      values: ["t3.large", "t3a.large", "m5.large", "m5a.large"]
  limits:
    resources:
      cpu: 1000
      memory: 1000Gi
  provider:
    subnetSelector:
      karpenter.sh/discovery: "true"
    securityGroupSelector:
      karpenter.sh/discovery: "true"
    tags:
      karpenter.sh/discovery: "true"
  ttlSecondsAfterEmpty: 30
  ttlSecondsUntilExpired: 2592000 # 30 days
```

Apply this with:

```bash
kubectl apply -f provisioner.yaml
```

## Best Practices

1. **Resource Limits**: Set appropriate resource limits in your Provisioner to control costs.

2. **Instance Diversity**: Specify multiple instance types to increase availability and optimize costs.

3. **Tagging Strategy**: Use consistent tags for resources managed by Karpenter.

4. **Subnet Selection**: Ensure Karpenter can provision nodes in appropriate subnets.

5. **TTL Configuration**:
   - `ttlSecondsAfterEmpty`: How long to wait before removing empty nodes
   - `ttlSecondsUntilExpired`: Maximum node lifetime

6. **Monitoring**: Set up monitoring for Karpenter to track provisioning decisions and resource usage.

7. **Interruption Handling**: Configure proper interruption handling for Spot instances.

## Troubleshooting

1. **Check Karpenter Logs**:
   ```bash
   kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter -c controller
   ```

2. **Verify IAM Permissions**:
   Ensure the Karpenter controller has the necessary permissions to provision and terminate instances.

3. **Check Provisioner Configuration**:
   Verify that your Provisioner resource is correctly configured with appropriate requirements and limits.

4. **Node Provisioning Issues**:
   If nodes aren't being provisioned, check that the security groups, subnets, and instance types are correctly specified.

5. **OIDC Integration**:
   Verify that the OIDC provider is correctly configured for the Karpenter service account.
