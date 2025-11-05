resource "random_password" "docdb_admin" {
  length      = 20
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  # Safe special set (avoid quotes, @, /, etc.)
  override_special = "!#$%^*-_=+~"
}

locals {
  docdb_subnets = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

resource "aws_docdbelastic_cluster" "this" {
  name                    = "${local.name_prefix}-docdb-elastic"
  admin_user_name         = "docdbadmin"
  admin_user_password     = random_password.docdb_admin.result
  auth_type               = "PLAIN_TEXT"
  shard_capacity          = var.docdb_shard_capacity
  shard_count             = var.docdb_shard_count
  subnet_ids              = local.docdb_subnets
  vpc_security_group_ids  = [aws_security_group.docdb.id]
  backup_retention_period = 1

  tags = local.base_tags
}

locals {
  encoded_pass = urlencode(random_password.docdb_admin.result)

  mongo_uri = "mongodb://${aws_docdbelastic_cluster.this.admin_user_name}:${local.encoded_pass}@${aws_docdbelastic_cluster.this.endpoint}:27017/${var.mongodb_db}?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
}


resource "aws_secretsmanager_secret" "mongo_uri" {
  name = "${local.name_prefix}/mongodb-uri"
  tags = local.base_tags
}

resource "aws_secretsmanager_secret_version" "mongo_uri" {
  secret_id     = aws_secretsmanager_secret.mongo_uri.id
  secret_string = local.mongo_uri
}
