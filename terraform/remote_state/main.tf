# builds:
#   - backend s3 bucket to store main application terraform state
#   - dynamodb table to lock state during changes

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.1.5"
}

provider "aws" {
  region  = var.tf_state_bucket_region
  profile = var.aws_profile
}

resource "random_id" "terraform_state" {
  byte_length = 6
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "${var.tf_state_s3_bucket}-${random_id.terraform_state.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = var.tf_state_lock_table
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
