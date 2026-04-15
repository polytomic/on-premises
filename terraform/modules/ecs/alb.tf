locals {
  lb_public_subnets  = var.vpc_id == "" ? module.vpc[0].public_subnets : var.public_subnet_ids
  lb_private_subnets = var.vpc_id == "" ? module.vpc[0].private_subnets : var.private_subnet_ids
  lb_sgs             = length(var.load_balancer_security_groups) == 0 ? module.lb_sg.*.security_group_id : var.load_balancer_security_groups
  mcp_host           = trimspace(var.polytomic_mcp_host)
}

resource "aws_alb" "main" {
  name            = "${var.prefix}-alb"
  subnets         = var.load_balancer_internal ? local.lb_private_subnets : local.lb_public_subnets
  security_groups = local.lb_sgs
  internal        = var.load_balancer_internal

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-alb"
    }
  )

}

resource "aws_alb_target_group" "polytomic" {
  name        = "${var.prefix}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id
  target_type = "ip"
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-tg"
    }
  )

  health_check {
    healthy_threshold   = "3"
    interval            = "20"
    protocol            = "HTTP"
    matcher             = "200-299,401"
    timeout             = "3"
    path                = "/status.txt"
    unhealthy_threshold = "2"
    port                = var.polytomic_port
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = "300"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.main.id
  port              = 80
  protocol          = "HTTP"
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-http-listener"
    }
  )


  dynamic "default_action" {
    for_each = var.load_balancer_redirect_https ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.load_balancer_redirect_https ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_alb_target_group.polytomic.arn
    }
  }
}

resource "aws_alb_target_group" "mcp" {
  count       = var.polytomic_mcp_enabled ? 1 : 0
  name        = "${var.prefix}-mcp-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id
  target_type = "ip"
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-mcp-tg"
    }
  )

  health_check {
    healthy_threshold   = "3"
    interval            = "20"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/healthz"
    unhealthy_threshold = "2"
    port                = "3000"
  }
}

resource "aws_alb_listener_rule" "mcp" {
  count        = var.polytomic_mcp_enabled ? 1 : 0
  listener_arn = aws_alb_listener.http.arn

  lifecycle {
    precondition {
      condition     = local.mcp_host != ""
      error_message = "polytomic_mcp_host must be set to a non-empty hostname when polytomic_mcp_enabled is true."
    }
  }

  # The module does not provision an HTTPS listener for MCP, so keep the
  # host-based rule on the HTTP listener instead of redirecting it away.
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.mcp[0].arn
  }

  condition {
    host_header {
      values = [local.mcp_host]
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-mcp-rule"
    }
  )
}
