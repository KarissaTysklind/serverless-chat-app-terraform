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

# Website S3 Bucket Files
resource "aws_s3_object" "uploadfiles" {
    for_each = fileset("./website-files/Site/", "**")
    bucket = aws_s3_bucket.website.id
    key = each.value
    source = "./website-files/Site/${each.value}" 
}
