# builds:
#   - s3 bucket for object storage
#   - cloudfront distribution to for signed s3 requests

# ==============================================
# Project setup

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.1.5"

  backend "s3" {}
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}


# ==============================================
# S3 bucket for hosting sample objects

module "sample_s3_bucket" {
  source = "./modules/private_s3_bucket"

  bucket_name = "${var.sample_s3_bucket_name}-${random_id.sample_s3_bucket.hex}"
}

resource "random_id" "sample_s3_bucket" {
  byte_length = 6
}

# ==============================================
# Sample S3 objects

resource "aws_s3_object" "sample-image" {
  bucket = module.sample_s3_bucket.bucket.id
  key    = basename("./assets/jessie.jpg")
  source = "./assets/jessie.jpg"
  etag   = filemd5("./assets/jessie.jpg")
}

# ==============================================
# Cloudfront distribution for accessing s3 object using signed URLs

# move to module

resource "aws_cloudfront_origin_access_identity" "cloudfront_s3_oia" {
  comment = "OIA to access sample s3 bucket"
}

data "aws_iam_policy_document" "cloudfront_sample_s3_oia" {
  statement {
    sid       = "S3GetObjectForCloudFront"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${module.sample_s3_bucket.bucket.id}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloudfront_s3_oia.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_sample_s3_oia" {
  bucket = module.sample_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.cloudfront_sample_s3_oia.json
}

resource "aws_cloudfront_public_key" "cloudfront_s3" {
  comment     = "UTF-8 Content Disposition Sample Key"
  encoded_key = file("../../keys/cloudfront_s3.pub")
  name        = "cloudfront-s3-key"
}

resource "aws_cloudfront_key_group" "cloudfront_s3" {
  comment = "UTF-8 Content Disposition Sample Key Group"
  items   = [aws_cloudfront_public_key.cloudfront_s3.id]
  name    = "cloudfront-s3-key-group"
}

resource "aws_cloudfront_distribution" "cloudfront_s3_proxy" {
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = module.sample_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = module.sample_s3_bucket.bucket.id

    # OIA required for s3 signed urls
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_s3_oia.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = module.sample_s3_bucket.bucket.id
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

# add signed url key groups