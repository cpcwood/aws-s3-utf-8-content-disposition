require 'cgi'
require_relative '../lib/cloudfront_url_signer'

domain = `../tools/output cloudfront_s3_domain_name`
sample_image_key = `../tools/output sample_s3_image_key`
key_pair_id = `../tools/output cloudfront_signing_key_pair_id`
private_key_path = "../keys/cloudfront_s3.pem"

cloudfront_url_signer = CloudfrontUrlSigner.new(domain:, key_pair_id:, private_key_path:)

download_filename = "고양이.jpg"

query_string = {
  "response-content-disposition" => CGI.escape("attachment; filename*= UTF-8''#{CGI.escape(download_filename)}"),
  "response-content-type" => "image/jpeg"
}

puts cloudfront_url_signer.sign(object_key: sample_image_key, query_string_hash: query_string)
