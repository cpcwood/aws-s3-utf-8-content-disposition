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

module "private_s3_bucket" {
  source = "./modules/private_s3_bucket"

  bucket_name = "${var.sample_s3_bucket_name}-${random_id.private_s3_bucket.hex}"
}

resource "random_id" "private_s3_bucket" {
  byte_length = 6
}

# ==============================================
# Sample S3 objects


# ==============================================
# Cloudfront distribution for accessing s3 object using signed URLs

