output "service_name" {
  description = <<-EOT
    The VPC Endpoint Service name. Send this string to your Polytomic Solutions
    Engineer — they will configure Polytomic's side to create a VPC endpoint
    against it.
  EOT
  value       = aws_vpc_endpoint_service.pl.service_name
}

output "service_id" {
  description = "The VPC Endpoint Service ID."
  value       = aws_vpc_endpoint_service.pl.id
}

output "nlb_arn" {
  value = aws_lb.pl.arn
}

output "target_ip" {
  description = "RDS IP resolved at apply time and registered as the NLB target."
  value       = data.dns_a_record_set.rds.addrs[0]
}
