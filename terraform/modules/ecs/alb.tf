locals {
  lb_public_subnets  = var.vpc_id == "" ? module.vpc[0].public_subnets : var.public_subnet_ids
  lb_private_subnets = var.vpc_id == "" ? module.vpc[0].private_subnets : var.private_subnet_ids
  lb_sgs             = length(var.lb_override_sgs) == 0 ? [module.lb_sg.security_group_id] : var.load_balancer_security_groups
}

resource "aws_alb" "main" {
  name            = "${var.prefix}-alb"
  subnets         = var.load_balancer_internal ? local.lb_private_subnets : local.lb_public_subnets
  security_groups = local.lb_sgs
  internal        = var.load_balancer_internal

  tags = var.tags

}

resource "aws_alb_target_group" "polytomic" {
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id
  target_type = "ip"
  tags        = var.tags

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
  tags              = var.tags


  default_action {
    target_group_arn = aws_alb_target_group.polytomic.id
    type             = "forward"
  }
}
