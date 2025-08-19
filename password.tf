resource "random_password" "this" {
  // Master password length constraints differ for each database engine. For more information, see the available settings when creating each DB instance.
  length  = 16
  special = true

  // The password for the master database user can include any printable ASCII character except /, ", @, or a space.
  // We're also excluding the following characters:
  // ':' - not allowed by DMS (Database Migration Service)
  // ';' - not allowed by DMS
  // '+' - not allowed by DMS
  // '%' - not allowed by DMS, confuses url encoding
  // '?' - confuses url encoding
  // '#' - confuses url encoding
  // '[' - confuses url encoding
  // ']' - confuses url encoding
  // '{' - confuses url encoding
  // '}' - confuses url encoding
  // '(' - issues with batch files
  // ')' - issues with batch files
  // '&' - issues with batch files
  // '!' - issues with batch files
  // '^' - issues with batch files
  // '<' - issues with batch files
  // '>' - issues with batch files
  override_special = "$*-_="

  lifecycle {
    ignore_changes = [override_special] // Prevent changing passwords for provisioned dbs
  }
}

resource "aws_secretsmanager_secret" "password" {
  name                    = "${local.resource_name}/master"
  tags                    = local.tags
  kms_key_id              = aws_kms_key.this.id
  recovery_window_in_days = local.is_prod_env ? 7 : 0
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id     = aws_secretsmanager_secret.password.id
  secret_string = jsonencode(tomap({ "username" = aws_rds_cluster.this.master_username, "password" = random_password.this.result }))
}
