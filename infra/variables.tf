variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "project" {
  type        = string
  default     = "hello-protocol"
}

variable "environment" {
  type        = string
  default     = "dev"
}

variable "mongodb_secret_name" {
  type        = string
  default     = "hello-protocol/mongodb-uri"
  description = "Secrets Manager secret name that stores the MongoDB connection string"
}

variable "mongodb_db" {
  type        = string
  default     = "app"
  description = "MongoDB database name"
}

variable "log_retention_days" {
  type        = number
  default     = 14
}

variable "lambda_memory_mb" {
  type        = number
  default     = 256
}

variable "tags" {
  type        = map(string)
  default     = {}
}
