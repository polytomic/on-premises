locals {
  preflight = {
    overrides = {
      containerOverrides = [
        {
          name = "sync"
          command = [
            "./ptctl",
            "sync",
            "preflight"
          ]
        }
      ]
    }
    network_config = {
      awsvpcConfiguration : {
        assignPublicIp = "DISABLED"
        subnets        = aws_ecs_service.sync.network_configuration[0].subnets
        securityGroups = aws_ecs_service.sync.network_configuration[0].security_groups
      }
    }
  }
}

resource "null_resource" "preflight" {

  count = var.polytomic_preflight_check ? 1 : 0

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOF
set -e
aws ecs run-task \
  --cluster ${var.ecs_cluster_name == "" ? module.ecs[0].cluster_arn : data.aws_ecs_cluster.cluster[0].arn} \
  --task-definition ${aws_ecs_task_definition.sync.family}:${aws_ecs_task_definition.sync.revision} \
  --launch-type FARGATE \
  --started-by "Polytomic Terraform Preflight" \
  --overrides '${jsonencode(local.preflight.overrides)}' \
  --network-configuration '${jsonencode(local.preflight.network_config)}' \
  --region '${var.region}' \
  --profile '${var.aws_profile}'
EOF
  }
}

