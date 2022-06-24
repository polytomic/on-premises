resource "aws_route53_zone" "primary" {
  name = "polytomic-sandbox.com"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "app.polytomic-sandbox.com"
  type    = "A"

  alias {
    name                   = module.polytomic-ecs.loadbalancer_dns_name
    zone_id                = module.polytomic-ecs.loadbalancer_zone_id
    evaluate_target_health = true
  }
}
