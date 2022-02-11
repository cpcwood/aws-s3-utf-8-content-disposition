variable "tf_state_bucket_region" {
  description = "AWS region the backend s3 bucket is created in"
  default     = "eu-west-2"
}

variable "tf_state_s3_bucket" {
  description = "AWS S3 bucket in which to store main application terraform state"
  default     = "aws-s3-utf-8-content-disposition-tf-state"
}

variable "tf_state_lock_table" {
  description = "AWS DynamoDB terraform state lock table name"
  default     = "aws-s3-utf-8-content-disposition-tf-state-lock-table"
}

variable "aws_profile" {
  description = "AWS profile to access AWS API"
  default     = "aws-s3-utf-8-content-disposition"
}
