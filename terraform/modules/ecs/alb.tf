resource "aws_alb" "main" {
  name            = "${var.prefix}-alb"
  subnets         = var.vpc_id == "" ? module.vpc[0].public_subnets : var.public_subnet_ids
  security_groups = [module.lb_sg.security_group_id]
}

resource "aws_alb_target_group" "polytomic" {
  name        = "${var.prefix}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id
  target_type = "ip"

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

  default_action {
    target_group_arn = aws_alb_target_group.polytomic.id
    type             = "forward"
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}
