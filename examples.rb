require 'cgi'
require_relative './lib/cloudfront_url_signer'

unless ['1', '2', '3'].include?(ARGV.first)
  puts 'The example script argument must be an example number'
end

def run_example
  example_number = ARGV.first.to_i
  puts send("example_#{example_number}".to_sym)
end

# fetch variables from infrastructure
def domain
  `./tools/output cloudfront_s3_domain_name`
end

def sample_image_key
  `./tools/output sample_s3_image_key`
end

def key_pair_id
  `./tools/output cloudfront_signing_key_pair_id`
end

def private_key_path
  "./keys/cloudfront_s3.pem"
end

# create url signer
def cloudfront_url_signer
  @cloudfront_url_signer ||= CloudfrontUrlSigner.new(domain:, key_pair_id:, private_key_path:)
end

def build_query_string(content_disposition)
  query_string = {
    "response-content-disposition" => content_disposition,
    "response-content-type" => "image/jpeg"
  }
end

# examples
def example_1
  filename = "jessie.jpg"
  content_disposition = CGI.escape("attachment; filename=#{filename};")
  query_string = build_query_string(content_disposition)

  cloudfront_url_signer.sign(object_key: sample_image_key, query_string:)
end

def example_2
  filename_legacy = "jessie.jpg"
  filename_utf8 = "고양이.jpg"
  content_disposition = CGI.escape("attachment; filename=#{filename_legacy}; filename*= UTF-8''#{filename_utf8}")
  query_string = build_query_string(content_disposition)

  cloudfront_url_signer.sign(object_key: sample_image_key, query_string:)
end

def example_3
  filename_legacy = "jessie.jpg"
  filename_utf8 = "고양이.jpg"
  filename_utf8_url_encoded = CGI.escape(filename_utf8)
  content_disposition = CGI.escape("attachment; filename=#{filename_legacy}; filename*= UTF-8''#{filename_utf8_url_encoded};")
  query_string = build_query_string(content_disposition)

  cloudfront_url_signer.sign(object_key: sample_image_key, query_string:)
end

run_example
