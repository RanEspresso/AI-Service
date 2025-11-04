# Resolve the secret by name so we can scope IAM to its ARN
data "aws_secretsmanager_secret" "mongodb" {
  name = var.mongodb_secret_name
}
