variable "name" {
  description = "OpenSearch domain name."
  type        = string
}

variable "subnet_ids" {
  description = "List of VPC subnet IDs where the OpenSearch endpoints are created."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the OpenSearch domain will be launched."
  type        = string
}

variable "engine_version" {
  description = "OpenSearch engine version (e.g., OpenSearch_2.11)."
  type        = string
  default     = "OpenSearch_2.11"
}

variable "instance_type" {
  description = "OpenSearch data node instance type."
  type        = string
  default     = "m6g.large.search"
}

variable "instance_count" {
  description = "Number of data nodes in the cluster."
  type        = number
  default     = 2
}

variable "dedicated_master_enabled" {
  description = "Whether dedicated master nodes are enabled."
  type        = bool
  default     = true
}

variable "dedicated_master_type" {
  description = "Dedicated master node instance type."
  type        = string
  default     = "m6g.large.search"
}

variable "dedicated_master_count" {
  description = "Number of dedicated master nodes."
  type        = number
  default     = 3
}

variable "zone_awareness_enabled" {
  description = "Whether zone awareness is enabled."
  type        = bool
  default     = true
}

variable "availability_zone_count" {
  description = "Number of availability zones for zone awareness. Defaults to 2 or 3 based on subnet count."
  type        = number
  default     = null
}

variable "ebs_enabled" {
  description = "Whether to enable EBS for data nodes."
  type        = bool
  default     = true
}

variable "volume_size" {
  description = "EBS volume size (GiB)."
  type        = number
  default     = 100
}

variable "volume_type" {
  description = "EBS volume type."
  type        = string
  default     = "gp3"
}

variable "snapshot_start_hour" {
  description = "Hour (0-23) for automated snapshots."
  type        = number
  default     = 0
}

variable "encrypt_at_rest_enabled" {
  description = "Enable encryption at rest."
  type        = bool
  default     = true
}

variable "encryption_kms_key_id" {
  description = "KMS key ID for encryption at rest."
  type        = string
  default     = null
}

variable "node_to_node_encryption_enabled" {
  description = "Enable node-to-node encryption."
  type        = bool
  default     = true
}

variable "enforce_https" {
  description = "Enforce HTTPS for the domain endpoint."
  type        = bool
  default     = true
}

variable "tls_security_policy" {
  description = "TLS security policy for the domain endpoint."
  type        = string
  default     = "Policy-Min-TLS-1-2-2019-07"
}

variable "advanced_options" {
  description = "Advanced OpenSearch options."
  type        = map(string)
  default     = {}
}

variable "access_policies" {
  description = "IAM policy document specifying access policies for the domain."
  type        = string
  default     = null
}

variable "create_iam_service_linked_role" {
  description = "Whether to create the service-linked role for OpenSearch."
  type        = bool
  default     = true
}

variable "ingress_allow_cidr_blocks" {
  description = "Ingress CIDR blocks allowed to access the domain."
  type        = list(string)
  default     = []
}

variable "ingress_allow_security_groups" {
  description = "Ingress security group IDs allowed to access the domain."
  type        = list(string)
  default     = []
}

variable "log_publishing_enabled" {
  description = "Enable CloudWatch log publishing."
  type        = bool
  default     = true
}

variable "log_types" {
  description = "Log types to publish to CloudWatch."
  type        = list(string)
  default     = ["INDEX_SLOW_LOGS", "SEARCH_SLOW_LOGS", "ES_APPLICATION_LOGS"]
}

variable "log_group_retention_in_days" {
  description = "Retention (in days) for OpenSearch CloudWatch logs."
  type        = number
  default     = 30
}

variable "zone_id" {
  description = "Route 53 zone ID for the optional DNS record."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
