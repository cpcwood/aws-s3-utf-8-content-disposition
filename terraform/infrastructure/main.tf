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

resource "aws_s3_object" "sample_image" {
  bucket = module.sample_s3_bucket.bucket.id
  key    = "not-at-cat.jpg"
  source = "./assets/jessie.jpg"
  etag   = filemd5("./assets/jessie.jpg")
}

# ==============================================
# CloudFront distribution for accessing s3 object using signed URLs

module "cloudfront_s3" {
  source = "./modules/private_cloudfront_s3"

  aws_s3_bucket           = module.sample_s3_bucket.bucket
  public_signing_key_path = "../../keys/cloudfront_s3.pub"
}