resource "aws_security_group" "this" {
  vpc_id      = local.vpc_id
  name        = local.resource_name
  tags        = merge(local.tags, { Name = local.resource_name })
  description = "Managed by Terraform"
}

resource "aws_security_group_rule" "this-from-vpc" {
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = local.port
  to_port           = local.port
  cidr_blocks       = [local.vpc_cidr]

  count = var.allow_private_access ? 1 : 0
}
