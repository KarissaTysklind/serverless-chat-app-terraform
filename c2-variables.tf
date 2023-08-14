variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Bucket variables

variable "s3_bucket_name" {
  type    = string
  default = "kt-my-serverless-chat-app"
}

variable "website_bucket_force_destroy" {
  type    = bool
  default = true
}

variable "website_bucket_acl" {
  type    = string
  default = "public-read"
}

variable "www_website_redirect_enabled" {
  type    = bool
  default = false
}