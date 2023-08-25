# Website S3 Bucket
resource "aws_s3_bucket" "website" {
  bucket        = var.s3_bucket_name
  force_destroy = var.website_bucket_force_destroy
}

resource "aws_s3_bucket_server_side_encryption_configuration" "website" {
  bucket = aws_s3_bucket.website.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_block" {
  depends_on = [aws_s3_bucket_ownership_controls.website]
  bucket     = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "website" {
  depends_on = [aws_s3_bucket_ownership_controls.website]
  bucket     = aws_s3_bucket.website.id
  policy = templatefile("${path.module}/policies/s3_website_bucket_policy.json", {
    bucket_name = var.s3_bucket_name
  })
}

locals {
  content_type_map = {
   "js" = "application/json"
   "html" = "text/html"
   "css"  = "text/css"
   "ini" = "binary/octet-stream"
  }
}

resource "aws_s3_object" "uploadfiles" {
  depends_on = [local_file.site_templates, aws_s3_bucket_policy.website]

  for_each = fileset("${path.module}/site/", "**/*")
  bucket   = aws_s3_bucket.website.id
  key      = each.value
  source   = "./site/${each.value}"
  content_type = lookup(local.content_type_map, split(".", "${each.value}")[1], "text/html")
  acl = "public-read"
  
  
}

resource "local_file" "site_templates" {
  for_each = fileset("${path.module}/templates/site_js/", "**")

  content = templatefile("${path.module}/templates/site_js/${each.value}", {
    user_pool_id = "${aws_cognito_user_pool.users.id}"
    client_id    = "${aws_cognito_user_pool_client.chat.id}"
  })

  filename = "${path.module}/site/js/${each.value}"
}

# CloudFront Configuration

data "aws_cloudfront_cache_policy" "cache_policy" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "website_distribution" {
  aliases = []

  comment             = null
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = var.price_class
  retain_on_delete    = false
  wait_for_deployment = true

  default_root_object = "index.html"

  origin {
    domain_name         = "${var.s3_bucket_name}.s3-website-${var.aws_region}.amazonaws.com"
    origin_id           = "${var.s3_bucket_name}.s3-website-${var.aws_region}.amazonaws.com"
    connection_attempts = 3
    connection_timeout  = 10

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_protocol_policy   = "http-only"
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    target_origin_id       = "${var.s3_bucket_name}.s3-website-${var.aws_region}.amazonaws.com"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = data.aws_cloudfront_cache_policy.cache_policy.id

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

}


        