variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "hello-protocol"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "mongodb_db" {
  type    = string
  default = "app"
}

variable "docdb_shard_capacity" {
  type    = number
  default = 2
}

variable "docdb_shard_count" {
  type    = number
  default = 1
}

variable "log_retention_days" {
  type    = number
  default = 14
}

variable "lambda_memory_mb" {
  type    = number
  default = 256
}

variable "tags" {
  type    = map(string)
  default = {}
}
