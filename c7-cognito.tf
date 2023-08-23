resource "aws_cognito_user_pool" "users" {
  name = var.cognito_user_pool_name

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  alias_attributes         = ["preferred_username"]
  auto_verified_attributes = ["email"]
  deletion_protection      = "ACTIVE"

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  mfa_configuration = "OFF"

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = false
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  username_configuration {
    case_sensitive = false
  }
}

resource "aws_cognito_user_pool_client" "chat" {
  name = "Website"
  user_pool_id = aws_cognito_user_pool.users.id
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

