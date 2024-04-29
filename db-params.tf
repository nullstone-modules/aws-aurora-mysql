locals {
  // Can only contain alphanumeric and hyphen characters
  param_group_name = "${local.resource_name}-mysql${replace(replace(var.mysql_version, ".", "-"), "_", "-")}"
}


resource "aws_rds_cluster_parameter_group" "this" {
  name_prefix = local.param_group_name
  family      = "aurora-mysql${var.mysql_version}"
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
      name  = parameter.key
      value = parameter.value
    }
  }
}
