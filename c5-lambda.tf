# Define Source-Code Archive
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.lambda_bucket_name
}

# Define Locals for Lambda Functions 
locals {
  lambda_functions = {
    conversation_POST = {
      template_file   = "chat_conversation_POST.tpl"
      js_file         = "chat_conversation_POST.js"
      zip_output_path = "${path.module}/lambda/chat_conversation_POST.zip"
      function_name   = "${var.function_name_prefix}-Chat-Conversation-POST"
    }

    messages_POST = {
      template_file   = "chat_messages_POST.tpl"
      js_file         = "chat_messages_POST.js"
      zip_output_path = "${path.module}/lambda/chat_messages_POST.zip"
      function_name   = "${var.function_name_prefix}-Chat-Messages-POST"
    }

    conversation_GET = {
      template_file   = "chat_conversation_GET.tpl"
      js_file         = "chat_conversation_GET.js"
      zip_output_path = "${path.module}/lambda/chat_conversation_GET.zip"
      function_name   = "${var.function_name_prefix}-Chat-Conversation-GET"

    }

    messages_GET = {
      template_file   = "chat_messages_GET.tpl"
      js_file         = "chat_messages_GET.js"
      zip_output_path = "${path.module}/lambda/chat_messages_GET.zip"
      function_name   = "${var.function_name_prefix}-Chat-Messages-GET"
    }

    users_GET = {
      template_file   = "chat_users_GET.tpl"
      js_file         = "chat_users_GET.js"
      zip_output_path = "${path.module}/lambda/chat_users_GET.zip"
      function_name   = "${var.function_name_prefix}-Chat-Users-GET"
    }
  }
}

# Create Lambda functions, S3 objects, and S3 triggers
resource "local_file" "lambda_functions" {
  for_each = local.lambda_functions

  content = templatefile("${path.module}/lambda/template_files/${each.value.template_file}", {
    conversation_table_name = var.dynamodb_conversation_table_name
    messages_table_name     = var.dynamodb_messages_table_name
    users_pool_id           = aws_cognito_user_pool.users.id
  })

  filename = "${path.module}/lambda/js_files/${each.value.js_file}"
}

data "archive_file" "chat" {
  for_each = local.lambda_functions

  type        = "zip"
  source_file = local_file.lambda_functions[each.key].filename
  output_path = local.lambda_functions[each.key].zip_output_path
}

resource "aws_s3_object" "lambda_functions" {
  depends_on = [data.archive_file.chat]
  for_each   = local.lambda_functions

  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${each.value.function_name}.zip"
  source = data.archive_file.chat[each.key].output_path
  etag   = filemd5(data.archive_file.chat[each.key].output_path)
}

resource "aws_lambda_function" "chat" {
  for_each = local.lambda_functions

  function_name = each.value.function_name
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = aws_s3_object.lambda_functions[each.key].key
  runtime       = "nodejs16.x"
  handler       = "index.handler"

  source_code_hash = data.archive_file.chat[each.key].output_base64sha256

  role = each.key == "chat_users_GET" ? aws_iam_role.lambda_cognito.arn : aws_iam_role.lambda_dynamodb.arn
}

# Define lambda permissions for API Gateway

resource "aws_lambda_permission" "aws_api_gateway_deployment" {
  depends_on    = [local_file.lambda_functions]
  for_each      = aws_lambda_function.chat
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chat[each.key].function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.chat.execution_arn}/*/*"
}

