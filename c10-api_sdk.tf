/*
data "aws_api_gateway_sdk" "chat" {
  rest_api_id = aws_api_gateway_rest_api.chat.id
  stage_name = aws_api_gateway_stage.chat.stage_name
  sdk_type = "javascript"
}

resource "aws_s3_object" "api_sdk" {
  bucket   = aws_s3_bucket.website.id
  key      = each.value
  source   = "./site/${each.value}"
}

resource "local_file" "chat_sdk" {
  filename = var.sdk_file_name
  content = data.aws_api_gateway_sdk.chat.body
}*/