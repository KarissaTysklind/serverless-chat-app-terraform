variable "aws_region" {
  type = string
}

# Bucket variables
variable "s3_bucket_name" {
  type = string
}

variable "lambda_bucket_name" {
  type = string
}

variable "website_bucket_force_destroy" {
  type    = bool
  default = true
}

variable "website_bucket_acl" {
  type    = string
  default = "private"
}

# CloudFront variables

variable "price_class" {
  type    = string
  default = "PriceClass_100"
}

# DynamoDB variables
variable "dynamodb_conversation_table_name" {
  type = string
}

variable "dynamodb_messages_table_name" {
  type = string
}

# IAM variables

variable "chat_dynamoDB_policy_name" {
  type = string
}

variable "lambda_cognito_policy_name" {
  type = string
}

variable "chat_dynamoDB_role_name" {
  type = string
}

variable "lambda_cognito_role_name" {
  type = string
}

# Cognito Variables
variable "cognito_user_pool_name" {
  type = string
}

#Lambda Variables
variable "function_name_prefix" {
  type = string
}

variable "lambda_layer_name" {
  type = string
}

# API variables

variable "api_chat_name" {
  type = string
}

variable "api_stage_name" {
  type = string
}

variable "sdk_file_name" {
  type = string
}

variable "endpoint_configuration" {
  type = string
}