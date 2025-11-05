output "http_api_invoke_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}

output "protocol_queue_url" {
  value = aws_sqs_queue.protocol.id
}

output "docdb_endpoint" {
  value = aws_docdbelastic_cluster.this.endpoint
}

output "mongo_uri_secret_name" {
  value = aws_secretsmanager_secret.mongo_uri.name
}
