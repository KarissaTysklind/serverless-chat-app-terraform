# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "cf_oai" {
  comment = "OAI to restrict access to AWS S3 content"
}

# Website S3 Bucket
resource "aws_s3_bucket" "website" {
  bucket        = var.s3_bucket_name
  force_destroy = var.website_bucket_force_destroy
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_block" {
  bucket = aws_s3_bucket.website.id

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

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.website]
  bucket     = aws_s3_bucket.website.id
  acl        = var.website_bucket_acl
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = templatefile("/policies/s3_website_bucket_policy.json", {
    bucket_name = var.s3_bucket_name
    cf_oai_arn  = aws_cloudfront_origin_access_identity.cf_oai.iam_arn
  })
}

resource "aws_s3_object" "uploadfiles" {
  for_each = fileset("./website-files/Site/", "**")
  bucket   = aws_s3_bucket.website.id
  key      = each.value
  source   = "./website-files/Site/${each.value}"
}

# CloudFront Configuration
resource "aws_cloudfront_distribution" "website_distribution" {
  aliases = []

  comment             = null
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
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
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"


    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn            = ""
    ssl_support_method             = "sni-only"
  }
}



        