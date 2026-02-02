AWS OpenSearch Service Terraform Module
======================================

Enterprise-ready Terraform module for provisioning an AWS OpenSearch Service domain in a VPC with HTTPS enforcement, encryption, log publishing, cost allocation tags, and optional Route 53 DNS.

## Usage

## Module Usage

Modules are designed to be sourced from your internal modules repository using HTTPS authentication. Use the following format in Terraform configurations:

```hcl
module "opensearch" {
  source = "git::https://git.edusuc.net/WEBFORX/Plateng-terraform-modules.git//aws/opensearch?ref=develop"

module "opensearch" {
  source = "git::https://github.com/egarbi/terraform-aws-es-cluster"

  name       = "example"
  vpc_id     = "vpc-xxxxx"
  subnet_ids = ["subnet-one", "subnet-two"]

  ingress_allow_cidr_blocks = ["10.20.0.0/16", "10.22.0.0/16"]
  access_policies           = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": "*",
      "Effect": "Allow",
      "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/example/*"
    }
  ]
}
POLICY

  tags = {
    Environment = "dev"
    Owner       = "platform"
  }
}
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
