module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = "polytomic-sandbox.com"
  zone_id     = aws_route53_zone.primary.zone_id

  subject_alternative_names = [
    "*.polytomic-sandbox.com",
    "app.polytomic-sandbox.com",
  ]

  wait_for_validation = false

}

# NOTE: This will fail until certificate is validated.
resource "aws_alb_listener" "https" {
  load_balancer_arn = module.polytomic-ecs.loadbalancer_arn
  certificate_arn   = module.acm.acm_certificate_arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    target_group_arn = module.polytomic-ecs.target_group_arn
    type             = "forward"
  }
}