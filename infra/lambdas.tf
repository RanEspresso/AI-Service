resource "null_resource" "http_npm_ci" {
  triggers = {
    # re-run if package.json changes
    hash = filesha256("${path.module}/../lambdas/http/package.json")
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/../lambdas/http"
    command     = "npm install --workspaces=false --omit=dev --no-audit --no-fund"
  }

}


data "archive_file" "http_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/http"
  output_path = "${path.module}/build/http.zip"
  depends_on  = [null_resource.http_npm_ci]
}

resource "aws_lambda_function" "http" {
  function_name = "${local.name_prefix}-http"
  role          = aws_iam_role.lambda_base_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = data.archive_file.http_zip.output_path
  timeout       = 10
  memory_size   = var.lambda_memory_mb

  environment {
    variables = {
      NODE_OPTIONS        = "--enable-source-maps"
      MONGODB_SECRET_NAME = aws_secretsmanager_secret.mongo_uri.name
      MONGODB_DB          = var.mongodb_db
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_group_ids = [aws_security_group.lambda.id]
  }

  tags = local.base_tags
}

resource "aws_cloudwatch_log_group" "http" {
  name              = "/aws/lambda/${aws_lambda_function.http.function_name}"
  retention_in_days = var.log_retention_days
  tags              = local.base_tags
}

resource "aws_apigatewayv2_integration" "http_lambda" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.http.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "ingest" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /ingest"
  target    = "integrations/${aws_apigatewayv2_integration.http_lambda.id}"
}

resource "aws_lambda_permission" "apigw_invoke_http" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.http.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "null_resource" "sqs_npm_ci" {
  triggers = {
    # re-run if package.json changes
    hash = filesha256("${path.module}/../lambdas/sqs/package.json")
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/../lambdas/sqs"
    command     = "npm install --workspaces=false --omit=dev --no-audit --no-fund"
  }
}

data "archive_file" "sqs_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/sqs"
  output_path = "${path.module}/build/sqs.zip"
  depends_on  = [null_resource.sqs_npm_ci]
}

resource "aws_lambda_function" "sqs" {
  function_name = "${local.name_prefix}-sqs"
  role          = aws_iam_role.lambda_base_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = data.archive_file.sqs_zip.output_path
  timeout       = 30
  memory_size   = var.lambda_memory_mb

  environment {
    variables = {
      NODE_OPTIONS        = "--enable-source-maps"
      MONGODB_SECRET_NAME = aws_secretsmanager_secret.mongo_uri.name
      MONGODB_DB          = var.mongodb_db
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_group_ids = [aws_security_group.lambda.id]
  }

  tags = local.base_tags
}

resource "aws_cloudwatch_log_group" "sqs" {
  name              = "/aws/lambda/${aws_lambda_function.sqs.function_name}"
  retention_in_days = var.log_retention_days
  tags              = local.base_tags
}

resource "aws_lambda_event_source_mapping" "sqs_mapping" {
  event_source_arn        = aws_sqs_queue.protocol.arn
  function_name           = aws_lambda_function.sqs.arn
  batch_size              = 10
  function_response_types = ["ReportBatchItemFailures"]
}
