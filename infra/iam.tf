data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_base_role" {
  name               = "${local.name_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags               = local.base_tags
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda_base_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "secrets_read" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [aws_secretsmanager_secret.mongo_uri.arn]
  }
}

resource "aws_iam_policy" "secrets_read" {
  name   = "${local.name_prefix}-secrets-read"
  policy = data.aws_iam_policy_document.secrets_read.json
}

resource "aws_iam_role_policy_attachment" "secrets_read_attach" {
  role       = aws_iam_role.lambda_base_role.name
  policy_arn = aws_iam_policy.secrets_read.arn
}

data "aws_iam_policy_document" "sqs_consume" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ChangeMessageVisibility",
      "sqs:GetQueueUrl",
      "sqs:ListQueues"
    ]
    resources = [aws_sqs_queue.protocol.arn]
  }
}

resource "aws_iam_policy" "sqs_consume" {
  name   = "${local.name_prefix}-sqs-consume"
  policy = data.aws_iam_policy_document.sqs_consume.json
}

resource "aws_iam_role_policy_attachment" "sqs_consume_attach" {
  role       = aws_iam_role.lambda_base_role.name
  policy_arn = aws_iam_policy.sqs_consume.arn
}

# Allow Lambda to create/manage ENIs in VPC
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_base_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}