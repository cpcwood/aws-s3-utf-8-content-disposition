# AWS CloudFront distriubtion to access private s3 bucket with signed URLs

resource "aws_cloudfront_origin_access_identity" "cloudfront_s3_oia" {
  comment = "OIA to access private s3 bucket"
}

data "aws_iam_policy_document" "cloudfront_s3_oia" {
  statement {
    sid       = "S3GetObjectForCloudFront"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.aws_s3_bucket.id}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloudfront_s3_oia.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_s3_oia" {
  bucket = var.aws_s3_bucket.id
  policy = data.aws_iam_policy_document.cloudfront_s3_oia.json
}

resource "aws_cloudfront_public_key" "cloudfront_s3" {
  comment     = "Key for signing CloudFront URLs"
  encoded_key = file(var.public_signing_key_path)
  name        = "cloudfront-s3-key"
}

resource "aws_cloudfront_key_group" "cloudfront_s3" {
  items   = [aws_cloudfront_public_key.cloudfront_s3.id]
  name    = "cloudfront-s3-key-group"
}

resource "aws_cloudfront_distribution" "cloudfront_s3_proxy" {
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = var.aws_s3_bucket.bucket_regional_domain_name
    origin_id   = var.aws_s3_bucket.id

    # OIA required for s3 signed urls
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_s3_oia.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.aws_s3_bucket.id
    trusted_key_groups     = [aws_cloudfront_key_group.cloudfront_s3.id]
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}