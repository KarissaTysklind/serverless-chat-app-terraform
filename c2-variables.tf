variable "aws_region" {
  type = string
}

# Bucket variables
variable "s3_bucket_name" {
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
