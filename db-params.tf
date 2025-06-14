locals {
  root_version = join(".", slice(split(".", var.mysql_version), 0, 2))
  // Can only contain alphanumeric and hyphen characters
  param_group_name = "${local.resource_name}-mysql${replace(replace(local.root_version, ".", "-"), "_", "-")}"
}

resource "aws_rds_cluster_parameter_group" "this" {
  name_prefix = local.param_group_name
  family      = "aurora-mysql${local.root_version}"
  tags        = local.tags
  description = "Aurora MySQL for ${local.block_name} (${local.env_name})"

  // When mysql version changes, we need to create a new one that attaches to the db
  //   because we can't destroy a parameter group that's in use
  lifecycle {
    create_before_destroy = true
  }

  dynamic "parameter" {
    for_each = var.custom_mysql_params

    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = contains(local.static_params, parameter.key) ? "pending-reboot" : "immediate"
    }
  }
}

locals {
  static_params = [
    "aurora_enhanced_binlog",
    "binlog_backup",
    "binlog-do-db",
    "binlog_format",
    "binlog-ignore-db",
    "binlog_replication_globaldb",
  ]
}
