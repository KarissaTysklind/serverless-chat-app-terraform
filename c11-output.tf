output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "user_pool_id" {
  value = aws_cognito_user_pool.users.id
}