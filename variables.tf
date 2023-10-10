variable "mysql_version" {
  type        = string
  default     = "8.0"
  description = <<EOF
The MySQL engine version to use. Valid values are 5.6, 5.7, and 8.0.
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

locals {
  port = 3306
}
