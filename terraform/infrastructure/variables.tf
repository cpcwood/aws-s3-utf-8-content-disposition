variable "aws_region" {
  description = "AWS region to build infrastructure in"
  default     = "eu-west-2"
}

variable "aws_profile" {
  description = "AWS profile to access AWS API"
  default     = "aws-s3-utf-8-content-disposition"
}

variable "sample_s3_bucket_name" {
  description = "AWS S3 bucket in which to store main application terraform state"
  default     = "aws-s3-utf-8-content-disposition"
}
