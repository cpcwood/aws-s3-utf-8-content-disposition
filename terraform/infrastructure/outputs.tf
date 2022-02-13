output "sample_s3_bucket" {
  value = module.sample_s3_bucket.bucket.id
}

output "cloudfront_s3_domain_name" {
  value = module.cloudfront_s3.domain_name
}
