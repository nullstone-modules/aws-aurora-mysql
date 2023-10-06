resource "aws_security_group" "this" {
  vpc_id      = local.vpc_id
  name        = local.resource_name
  tags        = merge(local.tags, { Name = local.resource_name })
  description = "Managed by Terraform"
}
