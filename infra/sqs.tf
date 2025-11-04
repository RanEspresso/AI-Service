resource "aws_sqs_queue" "dlq" {
  name                      = "${local.name_prefix}-protocol-dlq"
  message_retention_seconds = 1209600 # 14 days
  tags = local.base_tags
}

resource "aws_sqs_queue" "protocol" {
  name                       = "${local.name_prefix}-protocol-queue"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600 # 4 days
  redrive_policy             = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })
  tags = local.base_tags
}
