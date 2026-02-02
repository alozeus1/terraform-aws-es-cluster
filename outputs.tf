output "opensearch_arn" {
  description = "Amazon Resource Name (ARN) of the OpenSearch domain."
  value       = aws_opensearch_domain.opensearch.arn
}

output "opensearch_domain_id" {
  description = "Unique identifier for the OpenSearch domain."
  value       = aws_opensearch_domain.opensearch.domain_id
}

output "opensearch_endpoint" {
  description = "Domain-specific endpoint used for OpenSearch requests."
  value       = aws_opensearch_domain.opensearch.endpoint
}

output "opensearch_dashboard_endpoint" {
  description = "Domain-specific endpoint for OpenSearch Dashboards."
  value       = aws_opensearch_domain.opensearch.dashboard_endpoint
}

output "opensearch_security_group_id" {
  description = "Security group ID created for OpenSearch access."
  value       = aws_security_group.opensearch.id
}

output "opensearch_vpc_id" {
  description = "VPC ID where the OpenSearch domain is created."
  value       = aws_opensearch_domain.opensearch.vpc_options[0].vpc_id
}

output "opensearch_availability_zones" {
  description = "Availability zones used by the OpenSearch domain."
  value       = aws_opensearch_domain.opensearch.vpc_options[0].availability_zones
}
