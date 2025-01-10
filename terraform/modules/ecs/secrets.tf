resource "aws_secretsmanager_secret" "task_secrets" {
  name_prefix             = "${var.prefix}-ecs-task-secrets-"
  description             = "managed via terraform"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "task_secrets_version" {
  secret_id     = aws_secretsmanager_secret.task_secrets.id
  secret_string = jsonencode(merge(local.deployment_secrets, local.standard_secrets, var.extra_secrets))
}
