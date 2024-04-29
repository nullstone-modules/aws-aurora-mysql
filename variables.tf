variable "mysql_version" {
  type        = string
  default     = "8.0"
  description = <<EOF
The MySQL engine version to use. The most common values are 5.6, 5.7, and 8.0. You can also provide a specific version number, such as 8.0.mysql_aurora.3.06.0 if needed.
EOF
}

variable "instance_class" {
  type        = string
  default     = "db.t3.medium"
  description = <<EOF
The instance class to use for each instance. Valid values can be found here and are based on a combination of variables.
https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html
EOF
}

variable "instance_count" {
  type        = number
  default     = 1
  description = "The number of instances to create"
}

variable "backup_retention_period" {
  type        = number
  default     = 5
  description = "The number of days that each backup is retained"
}

variable "enable_performance_insights" {
  type        = bool
  default     = false
  description = "Enable performance insights"
}

variable "custom_mysql_params" {
  type        = map(string)
  default     = {}
  description = <<EOF
This is a dictionary of parameters to custom-configure the MySQL postgres instance.
For a list of parameters, see https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.Parameters.html
EOF
}

locals {
  port = 3306
}
