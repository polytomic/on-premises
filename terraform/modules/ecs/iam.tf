data "aws_iam_policy_document" "polytomic_task" {
  statement {
    sid = "PolytomicAccess"

    actions = [
      "s3:*",
    ]

    resources = concat(
      tolist([
        for bucket in module.s3_bucket : "${bucket.s3_bucket_arn}/*"
      ]),
      tolist([
        for bucket in module.s3_bucket : "${bucket.s3_bucket_arn}"
      ])
    )
  }
  statement {
    sid = "PolytomicECSExec"

    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "ecs:ListContainerInstances",
      "ecs:DescribeContainerInstances",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:UpdateContainerAgent",
      "ecs:StartTask",
      "ecs:StopTask",
      "ecs:RunTask",
      "ecs:TagResource",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues",

    ]

    resources = ["*"]
  }

  statement {
    sid = "PolytomicPassRole"
    actions = [
      "iam:PassRole",

    ]
    resources = ["*"]
  }


}

data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "polytomic_ecs_task_role" {
  name               = "${var.prefix}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-ecs-task-role"
  })
}


resource "aws_iam_role_policy" "polytomic_ecs_task_policy" {
  name   = "${var.prefix}-ecs-task-policy"
  role   = aws_iam_role.polytomic_ecs_task_role.id
  policy = data.aws_iam_policy_document.polytomic_task.json
}


data "aws_iam_policy_document" "polytomic_execution" {
  statement {
    sid = "PolytomicAccess"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetAuthorizationToken",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "elasticfilesystem:*",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "polytomic_ecs_execution_role" {
  name               = "${var.prefix}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-ecs-execution-role"
  })
}


resource "aws_iam_role_policy" "polytomic_ecs_execution_policy" {
  name   = "${var.prefix}-ecs-execuition_policy"
  role   = aws_iam_role.polytomic_ecs_execution_role.id
  policy = data.aws_iam_policy_document.polytomic_execution.json
}


data "aws_iam_policy_document" "polytomic_stats_reporter" {
  count = var.enable_stats ? 1 : 0

  statement {
    actions = [
      "ecs:RunTask",
      "ecs:TagResource",
    ]
    resources = [
      "${aws_ecs_task_definition.stats_reporter[0].arn}"
    ]
  }


  statement {
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "${aws_iam_role.polytomic_ecs_task_role.arn}",
      "${aws_iam_role.polytomic_ecs_execution_role.arn}"
    ]
  }


}

resource "aws_iam_role" "polytomic_stats_reporter_role" {
  count              = var.enable_stats ? 1 : 0
  name               = "${var.prefix}-stats-reporter-role"
  assume_role_policy = data.aws_iam_policy_document.events_assume_role_policy.json
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-stats-reporter-role"
  })
}


resource "aws_iam_role_policy" "polytomic_stats_reporter_policy" {
  count  = var.enable_stats ? 1 : 0
  name   = "${var.prefix}-stats-reporter-policy"
  role   = aws_iam_role.polytomic_stats_reporter_role[0].id
  policy = data.aws_iam_policy_document.polytomic_stats_reporter[0].json
}

data "aws_iam_policy_document" "events_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}
