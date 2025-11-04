output "http_api_id" {
  value = aws_apigatewayv2_api.http_api.id
}

output "http_api_invoke_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}

output "protocol_queue_url" {
  value = aws_sqs_queue.protocol.id
}

output "dlq_url" {
  value = aws_sqs_queue.dlq.id
}
