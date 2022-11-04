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
  value       = local.environment.env.DEPLOYMENT_API_KEY
  description = "API key used to authenticate with the Polytomic management API."
}

output "override_subnets" {
  value = aws_ecs_service.sync.network_configuration[0].subnets
}

output "override_sgs" {
  value = aws_ecs_service.sync.network_configuration[0].security_groups
}

output "override_task_definition" {
  value = "${aws_ecs_task_definition.sync.family}:${aws_ecs_task_definition.sync.revision}"
}

output "cluster_arn" {
  value = var.ecs_cluster_name == "" ? module.ecs[0].cluster_arn : data.aws_ecs_cluster.cluster[0].arn
}