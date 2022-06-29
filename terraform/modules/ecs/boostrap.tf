locals {
  bootstrap = {
    overrides = {
      containerOverrides = [
        {
          name = "sync"
          command = [
            "ptctl",
            "--name=${vars.polytomic_workspace_name}",
            "--domain=${polytomic_sso_domain}",
            "--worksos_id=${vars.polytomic_workos_org_id}",
            "--users=${vars.polytomic_root_user}",
            "--yes",
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

resource "null_resource" "boostrap" {

  count = var.polytomic_bootstrap ? 1 : 0

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOF
set -e
aws ecs run-task \
  --cluster ${var.ecs_cluster_name == "" ? module.ecs[0].cluster_arn : data.aws_ecs_cluster.cluster[0].arn} \
  --task-definition ${aws_ecs_task_definition.sync.family}:${aws_ecs_task_definition.sync.revision} \
  --launch-type FARGATE \
  --started-by "Polytomic Terraform" \
  --overrides '${jsonencode(local.bootstrap.overrides)}' \
  --network-configuration '${jsonencode(local.bootstrap.network_config)}' \
  --region '${var.region}'
EOF
  }
}