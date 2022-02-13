variable "aws_s3_bucket" {
  description = "AWS S3 bucket for CloudFront to proxy"
}

variable "public_signing_key_path" {
  description = "Path to the public key of the pair used for signing CloudFront URLs"
}