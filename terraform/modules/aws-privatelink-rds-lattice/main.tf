// Security group for the Resource Gateway. Only needs egress to RDS; return
// traffic is handled by conntrack. AWS service prefixes handle ingress from
// the Lattice data plane, so no explicit ingress rule is required here.
resource "aws_security_group" "resource_gateway" {
  name        = "${var.name}-rg"
  description = "Polytomic PrivateLink resource gateway egress to RDS"
  vpc_id      = var.vpc_id

  egress {
    from_port       = var.rds_port
    to_port         = var.rds_port
    protocol        = "tcp"
    security_groups = [var.rds_security_group_id]
    description     = "Egress to RDS"
  }

  tags = var.tags
}

// The critical rule most manual setups miss — RDS must allow inbound from the
// resource gateway's security group.
resource "aws_security_group_rule" "rds_from_resource_gateway" {
  type                     = "ingress"
  from_port                = var.rds_port
  to_port                  = var.rds_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.resource_gateway.id
  security_group_id        = var.rds_security_group_id
  description              = "Allow Polytomic PrivateLink resource gateway to reach RDS"
}

resource "aws_vpclattice_resource_gateway" "pl" {
  name               = "${var.name}-rg"
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  security_group_ids = [aws_security_group.resource_gateway.id]
  ip_address_type    = "IPV4"

  tags = var.tags
}

resource "aws_vpclattice_resource_configuration" "pl" {
  name = "${var.name}-rc"
  type = "SINGLE"

  resource_gateway_identifier = aws_vpclattice_resource_gateway.pl.id

  port_ranges = [tostring(var.rds_port)]
  protocol    = "TCP"

  resource_configuration_definition {
    dns_resource {
      domain_name     = var.rds_host
      ip_address_type = "IPV4"
    }
  }

  tags = var.tags
}

resource "aws_ram_resource_share" "pl" {
  name                      = "${var.name}-rc"
  allow_external_principals = true

  tags = var.tags
}

resource "aws_ram_resource_association" "pl" {
  resource_arn       = aws_vpclattice_resource_configuration.pl.arn
  resource_share_arn = aws_ram_resource_share.pl.arn
}

resource "aws_ram_principal_association" "pl" {
  principal          = var.polytomic_aws_account_id
  resource_share_arn = aws_ram_resource_share.pl.arn
}
