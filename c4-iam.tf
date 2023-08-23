# Fetch required Data
data "aws_caller_identity" "current" {}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "doc-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
  version = "2012-10-17"
}

# IAM Policies
resource "aws_iam_policy" "chat_dynamoDB" {
  name = var.chat_dynamoDB_policy_name
  policy = templatefile("${path.module}/policies/lambda-data.json", {
    dynamodb_table1 = var.dynamodb_conversation_table_name
    dynamodb_table2 = var.dynamodb_messages_table_name
    region          = var.aws_region
    account_id      = "${data.aws_caller_identity.current.account_id}"
  })
}

resource "aws_iam_policy" "lambda-cognito" {
  name = var.lambda_cognito_policy_name
  policy = templatefile("${path.module}/policies/lambda-cognito.json", {
    account_id = "${data.aws_caller_identity.current.account_id}"
    region     = var.aws_region
    pool_id    = "${aws_cognito_user_pool.users.id}"
  })
}

# IAM Roles
resource "aws_iam_role" "lambda_dynamodb" {
  name                = var.chat_dynamoDB_role_name
  assume_role_policy  = jsonencode(data.aws_iam_policy_document.doc-policy)
  managed_policy_arns = [aws_iam_policy.chat_dynamoDB.arn, data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn]
}

resource "aws_iam_role" "lambda_cognito" {
  name                = var.lambda_cognito_role_name
  assume_role_policy  = jsonencode(data.aws_iam_policy_document.doc-policy)
  managed_policy_arns = [aws_iam_policy.lambda-cognito.arn, data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn]
}

