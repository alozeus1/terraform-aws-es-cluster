locals {
  availability_zone_count = var.availability_zone_count != null ? var.availability_zone_count : (length(var.subnet_ids) >= 3 ? 3 : 2)
}

resource "aws_security_group" "opensearch" {
  name        = var.name
  description = "Security group for OpenSearch access"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_security_group_rule" "secure_cidrs" {
  count = length(var.ingress_allow_cidr_blocks) > 0 ? 1 : 0

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = var.ingress_allow_cidr_blocks

  security_group_id = aws_security_group.opensearch.id
}

resource "aws_security_group_rule" "secure_sgs" {
  count = length(var.ingress_allow_security_groups)

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = element(var.ingress_allow_security_groups, count.index)

  security_group_id = aws_security_group.opensearch.id
}

resource "aws_security_group_rule" "egress_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.opensearch.id
}

resource "aws_iam_service_linked_role" "default" {
  count            = var.create_iam_service_linked_role ? 1 : 0
  aws_service_name = "opensearchservice.amazonaws.com"
  description      = "AWSServiceRoleForAmazonOpenSearchService Service-Linked Role"
}

resource "aws_cloudwatch_log_group" "opensearch" {
  for_each          = var.log_publishing_enabled && length(var.log_types) > 0 ? toset(var.log_types) : []
  name              = "/aws/opensearch/${var.name}/${lower(each.value)}"
  retention_in_days = var.log_group_retention_in_days
  tags              = var.tags
}

data "aws_iam_policy_document" "opensearch_logs" {
  count = var.log_publishing_enabled && length(var.log_types) > 0 ? 1 : 0

  statement {
    sid     = "OpenSearchLogPublishing"
    effect  = "Allow"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]

    resources = [
      for log_group in aws_cloudwatch_log_group.opensearch : "${log_group.arn}:*"
    ]

    principals {
      type        = "Service"
      identifiers = ["opensearchservice.amazonaws.com"]
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "opensearch" {
  count       = var.log_publishing_enabled && length(var.log_types) > 0 ? 1 : 0
  policy_name = "opensearch-${var.name}-log-publishing"
  policy_document = data.aws_iam_policy_document.opensearch_logs[0].json
}

resource "aws_opensearch_domain" "opensearch" {
  domain_name    = var.name
  engine_version = var.engine_version

  cluster_config {
    instance_type            = var.instance_type
    instance_count           = var.instance_count
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_type    = var.dedicated_master_type
    dedicated_master_count   = var.dedicated_master_count
    zone_awareness_enabled   = var.zone_awareness_enabled

    dynamic "zone_awareness_config" {
      for_each = var.zone_awareness_enabled ? [1] : []
      content {
        availability_zone_count = local.availability_zone_count
      }
    }
  }

  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  encrypt_at_rest {
    enabled    = var.encrypt_at_rest_enabled
    kms_key_id = var.encryption_kms_key_id
  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption_enabled
  }

  domain_endpoint_options {
    enforce_https       = var.enforce_https
    tls_security_policy = var.tls_security_policy
  }

  vpc_options {
    security_group_ids = [aws_security_group.opensearch.id]
    subnet_ids         = var.subnet_ids
  }

  access_policies  = var.access_policies
  advanced_options = var.advanced_options

  snapshot_options {
    automated_snapshot_start_hour = var.snapshot_start_hour
  }

  dynamic "log_publishing_options" {
    for_each = var.log_publishing_enabled && length(var.log_types) > 0 ? toset(var.log_types) : []
    content {
      log_type                 = log_publishing_options.value
      cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch[log_publishing_options.value].arn
      enabled                  = true
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })

  depends_on = [
    aws_iam_service_linked_role.default,
    aws_cloudwatch_log_resource_policy.opensearch,
  ]
}

resource "aws_route53_record" "main" {
  count   = var.zone_id != null && var.zone_id != "" ? 1 : 0
  zone_id = var.zone_id
  name    = var.name
  type    = "CNAME"
  ttl     = "300"

  records = [aws_opensearch_domain.opensearch.endpoint]
}
