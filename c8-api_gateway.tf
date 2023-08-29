# Define REST API
resource "aws_api_gateway_authorizer" "chat_cognito" {
  name          = "Cognito"
  rest_api_id   = aws_api_gateway_rest_api.chat.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = ["arn:aws:cognito-idp:${var.aws_region}:${data.aws_caller_identity.current.account_id}:userpool/${aws_cognito_user_pool.users.id}"]
}

resource "aws_api_gateway_rest_api" "chat" {
  name        = var.api_chat_name
  description = "This API will trigger lambda functions to deliver/recieve messages in the chat APP"
  endpoint_configuration {
    types = [var.endpoint_configuration]
  }
}

# Define API Resources: /conversations
resource "aws_api_gateway_resource" "chat_conversations" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  parent_id   = aws_api_gateway_rest_api.chat.root_resource_id
  path_part   = "conversations"
}

module "cors_conversations" {
  source          = "squidfunk/api-gateway-enable-cors/aws"
  api_id          = aws_api_gateway_rest_api.chat.id
  api_resource_id = aws_api_gateway_resource.chat_conversations.id
}

# conversations_GET resources
resource "aws_api_gateway_method" "conversations_GET" {
  rest_api_id   = aws_api_gateway_rest_api.chat.id
  resource_id   = aws_api_gateway_resource.chat_conversations.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.chat_cognito.id
}

resource "aws_api_gateway_integration" "conversations_GET" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_conversations.id
  http_method = aws_api_gateway_method.conversations_GET.http_method

  integration_http_method = "POST"
  content_handling        = "CONVERT_TO_TEXT"
  type                    = "AWS"
  uri                     = aws_lambda_function.chat["conversation_GET"].invoke_arn
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  request_templates = {
    "application/json" = <<EOF
    ${file("${path.module}/mapping_templates/Chat-Conversations-GET-Input_mapping.template")}
    EOF
  }
}

resource "aws_api_gateway_method_response" "conversations_GET" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_conversations.id
  http_method = aws_api_gateway_method.conversations_GET.http_method
  status_code = "200"
  response_models = {
    "application/json" = aws_api_gateway_model.chat_models["conversation_list"].name
  }
}

resource "aws_api_gateway_integration_response" "conversations_GET" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_conversations.id
  http_method = aws_api_gateway_method.conversations_GET.http_method
  status_code = "200"
}


# conversations_POST resources
resource "aws_api_gateway_method" "conversations_POST" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_conversations.id
  http_method = "POST"
  request_models = {
    "application/json" = aws_api_gateway_model.chat_models["new_conversation"].name
  }
  authorizer_id = aws_api_gateway_authorizer.chat_cognito.id
  authorization = "COGNITO_USER_POOLS"
}

resource "aws_api_gateway_integration" "conversations_POST" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_conversations.id
  http_method = aws_api_gateway_method.conversations_POST.http_method

  integration_http_method = "POST"
  content_handling        = "CONVERT_TO_TEXT"
  type                    = "AWS"
  uri                     = aws_lambda_function.chat["conversation_POST"].invoke_arn
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  request_templates = {
    "application/json" = <<EOF
    ${file("${path.module}/mapping_templates/Chat-Conversations-POST-Input_mapping.template")}
    EOF
  }
}

resource "aws_api_gateway_method_response" "conversations_POST" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_conversations.id
  http_method = aws_api_gateway_method.conversations_POST.http_method
  status_code = "200"
  response_models = {
  "application/json" = aws_api_gateway_model.chat_models["conversation_id"].name }
}

resource "aws_api_gateway_integration_response" "conversations_POST" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_conversations.id
  http_method = aws_api_gateway_method.conversations_POST.http_method
  status_code = "200"
}

# Define API Resources: /conversations/{id}
resource "aws_api_gateway_resource" "chat_id" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  parent_id   = aws_api_gateway_resource.chat_conversations.id
  path_part   = "{id}"
}

module "cors_conversation_id" {
  source          = "squidfunk/api-gateway-enable-cors/aws"
  api_id          = aws_api_gateway_rest_api.chat.id
  api_resource_id = aws_api_gateway_resource.chat_id.id
}

# conversation_GET resources
resource "aws_api_gateway_method" "conversation_GET" {
  rest_api_id   = aws_api_gateway_rest_api.chat.id
  resource_id   = aws_api_gateway_resource.chat_id.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.chat_cognito.id
}

resource "aws_api_gateway_integration" "conversation_GET" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_id.id
  http_method = aws_api_gateway_method.conversation_GET.http_method

  integration_http_method = "POST"
  content_handling        = "CONVERT_TO_TEXT"
  type                    = "AWS"
  uri                     = aws_lambda_function.chat["messages_GET"].invoke_arn
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  request_templates = {
    "application/json" = <<EOF
    ${file("${path.module}/mapping_templates/Chat-Messages-GET-Input_mapping.template")}
    EOF
  }
}

resource "aws_api_gateway_method_response" "conversation_GET" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_id.id
  http_method = aws_api_gateway_method.conversation_GET.http_method
  status_code = "200"
  response_models = {
  "application/json" = aws_api_gateway_model.chat_models["conversation"].name }
}

resource "aws_api_gateway_method_response" "conversation_GET_400" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_id.id
  http_method = aws_api_gateway_method.conversation_GET.http_method
  status_code = "401"
  response_models = {
  "application/json" = "Error" }
}

resource "aws_api_gateway_integration_response" "conversation_GET" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_id.id
  http_method = aws_api_gateway_method.conversation_GET.http_method
  status_code = aws_api_gateway_method_response.conversation_GET.status_code
}

resource "aws_api_gateway_integration_response" "conversation_GET_400" {
  rest_api_id       = aws_api_gateway_rest_api.chat.id
  resource_id       = aws_api_gateway_resource.chat_id.id
  http_method       = aws_api_gateway_method.conversation_GET.http_method
  status_code       = aws_api_gateway_method_response.conversation_GET_400.status_code
  selection_pattern = ".*unauthorized.*"
}

# conversation_POST resources
resource "aws_api_gateway_method" "conversation_POST" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_id.id
  http_method = "POST"
  request_models = {
  "application/json" = aws_api_gateway_model.chat_models["new_message"].name }
  authorizer_id = aws_api_gateway_authorizer.chat_cognito.id
  authorization = "COGNITO_USER_POOLS"
}

resource "aws_api_gateway_integration" "conversation_POST" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_id.id
  http_method = aws_api_gateway_method.conversation_POST.http_method

  integration_http_method = "POST"
  content_handling        = "CONVERT_TO_TEXT"
  type                    = "AWS"
  uri                     = aws_lambda_function.chat["messages_POST"].invoke_arn
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  request_templates = {
    "application/json" = <<EOF
    ${file("${path.module}/mapping_templates/Chat-Messages-POST-Input_mapping.template")}
    EOF
  }
}

resource "aws_api_gateway_method_response" "conversation_POST" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_id.id
  http_method = aws_api_gateway_method.conversation_POST.http_method
  status_code = "204"
}

resource "aws_api_gateway_integration_response" "conversation_POST" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_id.id
  http_method = aws_api_gateway_method.conversation_POST.http_method
  status_code = "204"
}

# Define API Resources: /cusers
resource "aws_api_gateway_resource" "chat_users" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  parent_id   = aws_api_gateway_rest_api.chat.root_resource_id
  path_part   = "users"
}

module "cors_users" {
  source          = "squidfunk/api-gateway-enable-cors/aws"
  api_id          = aws_api_gateway_rest_api.chat.id
  api_resource_id = aws_api_gateway_resource.chat_users.id
}

# users_GET resources
resource "aws_api_gateway_method" "users_GET" {
  rest_api_id   = aws_api_gateway_rest_api.chat.id
  resource_id   = aws_api_gateway_resource.chat_users.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.chat_cognito.id
}

resource "aws_api_gateway_integration" "users_GET" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_users.id
  http_method = aws_api_gateway_method.users_GET.http_method

  integration_http_method = "POST"
  content_handling        = "CONVERT_TO_TEXT"
  type                    = "AWS"
  uri                     = aws_lambda_function.chat["users_GET"].invoke_arn
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  request_templates = {
    "application/json" = <<EOF
    ${file("${path.module}/mapping_templates/Chat-Users-GET-Input_mapping.template")}
    EOF
  }
}

resource "aws_api_gateway_method_response" "users_GET" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_users.id
  http_method = aws_api_gateway_method.users_GET.http_method
  status_code = "200"
  response_models = {
    "application/json" = aws_api_gateway_model.chat_models["user_list"].name
  }
}

resource "aws_api_gateway_integration_response" "users_GET" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  resource_id = aws_api_gateway_resource.chat_users.id
  http_method = aws_api_gateway_method.users_GET.http_method
  status_code = "200"
}

# API Gateway Deployment
resource "aws_api_gateway_stage" "chat" {
  stage_name    = var.api_stage_name
  rest_api_id   = aws_api_gateway_rest_api.chat.id
  deployment_id = aws_api_gateway_deployment.chat.id
}

resource "aws_api_gateway_deployment" "chat" {
  depends_on  = [aws_api_gateway_integration.conversations_GET]
  rest_api_id = aws_api_gateway_rest_api.chat.id
}
