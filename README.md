AWS OpenSearch Service Terraform Module
======================================

Enterprise-ready Terraform module for provisioning an AWS OpenSearch Service domain in a VPC with HTTPS enforcement, encryption, log publishing, cost allocation tags, and optional Route 53 DNS.

## Module Usage

Modules are designed to be sourced from your internal modules repository using HTTPS authentication. Use the following format in Terraform configurations:

```hcl
module "opensearch" {
  source = "git::https://git.edusuc.net/WEBFORX/Plateng-terraform-modules.git//aws/opensearch?ref=develop"

  name       = "search-dev"
  vpc_id     = "vpc-xxxxx"
  subnet_ids = ["subnet-aaa", "subnet-bbb"]

  ingress_allow_cidr_blocks = ["10.20.0.0/16"]
  access_policies           = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": "*",
      "Effect": "Allow",
      "Resource": "arn:aws:es:us-east-1:123456789012:domain/search-dev/*"
    }
  ]
}
POLICY

  tags = {
    Environment = "dev"
    Owner       = "platform"
  }

  cost_tags = {
    CostCenter = "cc-1234"
    Product    = "search"
  }
}
```

## Step-by-step deployment guidance

1. **Confirm prerequisites**
   - VPC and subnets for the OpenSearch domain.
   - IAM permissions to create OpenSearch, security groups, and CloudWatch log groups.
   - (Optional) Route 53 hosted zone ID if you need a DNS record.

2. **Add the module to your environment**
   - In your live repo, add a folder like:
     `Plateng-terraform-live/aws/development/opensearch/`
   - Define your module configuration in `main.tf` using the example above.

3. **Pin the module version**
   - Use a tag, branch, or commit hash in the `source` URL (see Version Pinning below).

4. **Initialize and plan**
   ```bash
   terraform init
   terraform plan
   ```

5. **Apply to deploy**
   ```bash
   terraform apply
   ```

6. **Validate outputs**
   - Use `terraform output` to retrieve `opensearch_endpoint` and `opensearch_dashboard_endpoint`.

## Version Pinning

Always pin to a specific version or commit for production environments:

```hcl
# Pin to a specific tag
source = "git::https://git.edusuc.net/WEBFORX/Plateng-terraform-modules.git//aws/opensearch?ref=v1.0.0"

# Pin to a specific branch
source = "git::https://git.edusuc.net/WEBFORX/Plateng-terraform-modules.git//aws/opensearch?ref=develop"

# Pin to a specific commit
source = "git::https://git.edusuc.net/WEBFORX/Plateng-terraform-modules.git//aws/opensearch?ref=abc1234"
```

## Authentication

For HTTPS authentication, configure your Git credentials:

```bash
# Using credential helper
git config --global credential.helper store

# Or use a personal access token in the URL
source = "git::https://username:token@git.edusuc.net/WEBFORX/Plateng-terraform-modules.git//aws/opensearch?ref=develop"
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | OpenSearch domain name. | string | n/a | yes |
| subnet_ids | List of VPC subnet IDs where the OpenSearch endpoints are created. | list(string) | n/a | yes |
| vpc_id | VPC ID where the OpenSearch domain will be launched. | string | n/a | yes |
| engine_version | OpenSearch engine version (e.g., OpenSearch_2.11). | string | `"OpenSearch_2.11"` | no |
| instance_type | OpenSearch data node instance type. | string | `"m6g.large.search"` | no |
| instance_count | Number of data nodes in the cluster. | number | `2` | no |
| dedicated_master_enabled | Whether dedicated master nodes are enabled. | bool | `true` | no |
| dedicated_master_type | Dedicated master node instance type. | string | `"m6g.large.search"` | no |
| dedicated_master_count | Number of dedicated master nodes. | number | `3` | no |
| zone_awareness_enabled | Whether zone awareness is enabled. | bool | `true` | no |
| availability_zone_count | Number of availability zones for zone awareness. Defaults to 2 or 3 based on subnet count. | number | `null` | no |
| ebs_enabled | Whether to enable EBS for data nodes. | bool | `true` | no |
| volume_size | EBS volume size (GiB). | number | `100` | no |
| volume_type | EBS volume type. | string | `"gp3"` | no |
| snapshot_start_hour | Hour (0-23) for automated snapshots. | number | `0` | no |
| encrypt_at_rest_enabled | Enable encryption at rest. | bool | `true` | no |
| encryption_kms_key_id | KMS key ID for encryption at rest. | string | `null` | no |
| node_to_node_encryption_enabled | Enable node-to-node encryption. | bool | `true` | no |
| enforce_https | Enforce HTTPS for the domain endpoint. | bool | `true` | no |
| tls_security_policy | TLS security policy for the domain endpoint. | string | `"Policy-Min-TLS-1-2-2019-07"` | no |
| advanced_options | Advanced OpenSearch options. | map(string) | `{}` | no |
| access_policies | IAM policy document specifying access policies for the domain. | string | `null` | no |
| create_iam_service_linked_role | Whether to create the service-linked role for OpenSearch. | bool | `true` | no |
| ingress_allow_cidr_blocks | Ingress CIDR blocks allowed to access the domain. | list(string) | `[]` | no |
| ingress_allow_security_groups | Ingress security group IDs allowed to access the domain. | list(string) | `[]` | no |
| log_publishing_enabled | Enable CloudWatch log publishing. | bool | `true` | no |
| log_types | Log types to publish to CloudWatch. | list(string) | `[
  "INDEX_SLOW_LOGS",
  "SEARCH_SLOW_LOGS",
  "ES_APPLICATION_LOGS"
]` | no |
| log_group_retention_in_days | Retention (in days) for OpenSearch CloudWatch logs. | number | `30` | no |
| zone_id | Route 53 zone ID for the optional DNS record. | string | `null` | no |
| tags | Tags to apply to all resources. | map(string) | `{}` | no |
| cost_tags | Cost allocation tags to apply to all resources. | map(string) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| opensearch_arn | Amazon Resource Name (ARN) of the OpenSearch domain. |
| opensearch_domain_id | Unique identifier for the OpenSearch domain. |
| opensearch_endpoint | Domain-specific endpoint used for OpenSearch requests. |
| opensearch_dashboard_endpoint | Domain-specific endpoint for OpenSearch Dashboards. |
| opensearch_security_group_id | Security group ID created for OpenSearch access. |
| opensearch_vpc_id | VPC ID where the OpenSearch domain is created. |
| opensearch_availability_zones | Availability zones used by the OpenSearch domain. |
