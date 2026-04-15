data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "dns_a_record_set" "rds" {
  host = var.rds_host
}

resource "aws_lb" "pl" {
  name                             = "${var.name}-nlb"
  load_balancer_type               = "network"
  internal                         = true
  subnets                          = var.subnet_ids
  enable_cross_zone_load_balancing = true

  tags = var.tags
}

resource "aws_lb_target_group" "pl" {
  name        = "${var.name}-tg"
  target_type = "ip"
  protocol    = "TCP"
  port        = var.rds_port
  vpc_id      = var.vpc_id

  health_check {
    protocol = "TCP"
    port     = tostring(var.rds_port)
  }

  tags = var.tags
}

// RDS endpoints resolve to a single A record in practice (single-AZ writer
// or the current Multi-AZ writer), so we register exactly one IP target. A
// for_each over `data.dns_a_record_set.rds.addrs` would be more correct in
// principle but can't plan cleanly — the addrs aren't known until after the
// RDS data source resolves, and for_each keys must be known at plan time.
// `availability_zone` is intentionally omitted. AWS infers the AZ from the
// IP for in-VPC targets; setting `"all"` is only valid for targets outside
// the NLB's VPC and is rejected when the IP is in-VPC.
resource "aws_lb_target_group_attachment" "pl" {
  count            = 1
  target_group_arn = aws_lb_target_group.pl.arn
  target_id        = data.dns_a_record_set.rds.addrs[0]
  port             = var.rds_port
}

resource "aws_lb_listener" "pl" {
  load_balancer_arn = aws_lb.pl.arn
  protocol          = "TCP"
  port              = var.rds_port

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pl.arn
  }

  tags = var.tags
}

// Allow the NLB IP targets (sourced from within this VPC) to reach RDS.
resource "aws_security_group_rule" "rds_from_vpc" {
  type              = "ingress"
  from_port         = var.rds_port
  to_port           = var.rds_port
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  security_group_id = var.rds_security_group_id
  description       = "Allow Polytomic PrivateLink NLB to reach RDS"
}

resource "aws_vpc_endpoint_service" "pl" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.pl.arn]
  allowed_principals         = ["arn:aws:iam::${var.polytomic_aws_account_id}:root"]

  tags = var.tags
}
