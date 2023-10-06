resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/rds/instance/${local.resource_name}/mysql"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.this.arn
  tags              = local.tags
}

resource "aws_cloudwatch_log_group" "upgrade" {
  name              = "/aws/rds/instance/${local.resource_name}/upgrade"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.this.arn
  tags              = local.tags
}
