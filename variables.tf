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

variable "auto_upgrade_minor" {
  type        = bool
  default     = true
  description = <<EOF
Whether or not to automatically upgrade minor versions of the database.
These upgrades are performed during the maintenance window (See `maintenance_window` variable).
EOF
}

variable "maintenance_window" {
  type        = string
  default     = "Sat:03:00-Sat:03:30"
  description = <<EOF
A weekly time interval in which to performance maintenance (e.g. minor version upgrades, patches, etc.).
This window is configured using UTC time zone.
Syntax: "ddd:hh24:mi-ddd:hh24:mi"
Example: "Mon:00:00-Mon:03:00"
See [RDS Maintenance Window docs](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Maintenance.html#AdjustingTheMaintenanceWindow) for more information.
EOF
}

variable "allow_private_access" {
  type        = bool
  default     = false
  description = "Allow private access from any device in the VPC"
}

locals {
  port = 3306
}
