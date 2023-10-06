variable "mysql_version" {
  type        = string
  default     = "8.0"
  description = <<EOF
The MySQL engine version to use. Valid values are 5.6, 5.7, and 8.0.
EOF
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
  description = <<EOF
There are limitations based on a combination of variables: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html
EOF
}

variable "allocated_storage" {
  type        = number
  default     = 10
  description = "Allocated storage in GB"
}

variable "backup_retention_period" {
  type        = number
  default     = 5
  description = "The number of days that each backup is retained"
}

variable "high_availability" {
  type        = bool
  default     = false
  description = <<EOF
Enables high availability and failover support on the database instance.
By default, this is disabled. It is recommended to enable this in production environments.
In dev environments, it is best to turn off to save on costs.
EOF
}

locals {
  port = 3306
}
