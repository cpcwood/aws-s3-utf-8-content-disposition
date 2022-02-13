output "sample_s3_bucket" {
  value = module.sample_s3_bucket.bucket.id
}

output "sample_s3_image_key" {
  value = aws_s3_object.sample_image.id
}

output "cloudfront_s3_domain_name" {
  value = module.cloudfront_s3.domain_name
}

output "cloudfront_signing_key_pair_id" {
  value = module.cloudfront_s3.cloudfront_signing_key_pair_id
}