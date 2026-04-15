output "resource_configuration_arn" {
  description = <<-EOT
    The Lattice Resource Configuration ARN. Send this string to your Polytomic
    Solutions Engineer — they will configure Polytomic's side to create a
    Resource-type VPC endpoint against it.
  EOT
  value       = aws_vpclattice_resource_configuration.pl.arn
}

output "resource_gateway_id" {
  value = aws_vpclattice_resource_gateway.pl.id
}

output "ram_resource_share_arn" {
  value = aws_ram_resource_share.pl.arn
}
