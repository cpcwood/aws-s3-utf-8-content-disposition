output "domain_name" {
  value = aws_cloudfront_distribution.cloudfront_s3_proxy.domain_name
}

output "cloudfront_signing_key_pair_id" {
  value = aws_cloudfront_public_key.cloudfront_s3.id
}