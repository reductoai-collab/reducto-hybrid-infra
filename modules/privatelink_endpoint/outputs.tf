output "endpoint_id" {
  description = "ID of the VPC endpoint"
  value       = aws_vpc_endpoint.reducto.id
}

output "endpoint_state" {
  description = "State of the VPC endpoint (pendingAcceptance, pending, available, deleting, deleted, rejected, failed)"
  value       = aws_vpc_endpoint.reducto.state
}

output "dns_entries" {
  description = "DNS entries for the VPC endpoint"
  value       = aws_vpc_endpoint.reducto.dns_entry
}

output "network_interface_ids" {
  description = "Network interface IDs created for the endpoint"
  value       = aws_vpc_endpoint.reducto.network_interface_ids
}

output "security_group_id" {
  description = "Security group ID attached to the endpoint (if created by this module)"
  value       = length(aws_security_group.endpoint) > 0 ? aws_security_group.endpoint[0].id : null
}
