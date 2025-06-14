locals {
  ca_cert_identifier = "rds-ca-rsa2048-g1"
  // Limitations on master username: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html#RDS_Limits.Constraints
  invalid_usernames = [
    "rdsadmin",
    "admin",
    "root",
    "mysql",
    "test",
    "sys",
  ]
  master_username_fallback = "mysql_nullstone"
  prelim_master_username   = replace(data.ns_workspace.this.block_ref, "-", "_")

  master_username = contains(local.invalid_usernames, local.prelim_master_username) ? local.master_username_fallback : local.prelim_master_username
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                        = var.instance_count
  identifier                   = "${local.resource_name}-instance-${count.index}"
  cluster_identifier           = aws_rds_cluster.this.id
  instance_class               = var.instance_class
  engine                       = aws_rds_cluster.this.engine
  engine_version               = aws_rds_cluster.this.engine_version
  auto_minor_version_upgrade   = var.auto_upgrade_minor
  preferred_maintenance_window = var.maintenance_window
  ca_cert_identifier           = local.ca_cert_identifier

  copy_tags_to_snapshot = true
  tags                  = local.tags

  performance_insights_enabled = var.enable_performance_insights

  apply_immediately = true
}

resource "aws_rds_cluster" "this" {
  cluster_identifier              = local.resource_name
  db_subnet_group_name            = aws_db_subnet_group.this.name
  engine                          = "aurora-mysql"
  engine_mode                     = "provisioned"
  engine_version                  = var.mysql_version
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name
  allow_major_version_upgrade     = true
  preferred_maintenance_window    = var.maintenance_window
  storage_encrypted               = true
  port                            = local.port
  vpc_security_group_ids          = [aws_security_group.this.id]
  tags                            = local.tags

  iam_database_authentication_enabled = true
  master_username                     = local.master_username
  master_password                     = random_password.this.result

  apply_immediately = true

  // final_snapshot_identifier is unique to when an instance is launched
  // This prevents repeated launch+destroy from creating the same final snapshot and erroring
  // Changes to the name are ignored so it doesn't keep invalidating the instance
  final_snapshot_identifier = "${local.resource_name}-${replace(timestamp(), ":", "-")}"

  backup_retention_period = var.backup_retention_period
  preferred_backup_window = "02:00-03:00"

  enabled_cloudwatch_logs_exports = ["slowquery", "error"]

  lifecycle {
    ignore_changes = [master_username, final_snapshot_identifier]
  }

  depends_on = [aws_cloudwatch_log_group.this, aws_cloudwatch_log_group.upgrade]
}

resource "aws_db_subnet_group" "this" {
  name        = local.resource_name
  description = "MySQL db subnet group for mysql cluster"
  subnet_ids  = local.private_subnet_ids
  tags        = local.tags
}

resource "aws_iam_role" "monitoring" {
  name               = "${local.resource_name}-monitoring"
  assume_role_policy = data.aws_iam_policy_document.monitoring_assume.json
  tags               = local.tags
}

data "aws_iam_policy_document" "monitoring_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }

    // These conditions prevent the confused deputy problem
    // See https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.Enabling.html#USER_Monitoring.OS.confused-deputy
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:rds:${data.aws_region.this.name}:${data.aws_caller_identity.current.account_id}:db:${local.resource_name}"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  role       = aws_iam_role.monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
