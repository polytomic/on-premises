output "loadbalancer_dns_name" {
  value = aws_alb.main.dns_name
}

output "loadbalancer_zone_id" {
  value = aws_alb.main.zone_id
}

output "loadbalancer_arn" {
  value = aws_alb.main.arn
}

output "target_group_arn" {
  value = aws_alb_target_group.polytomic.id
}

output "deploy_api_key" {
  value = random_password.deployment_api_key.result
}