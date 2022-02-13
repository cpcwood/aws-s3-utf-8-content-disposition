require 'openssl'
require 'base64'
require 'json'

class CloudfrontUrlSigner
  attr_accessor :domain

  def initialize(domain:, key_pair_id:, private_key_path:, expiry_time: 600)
    @domain = domain
    @key_pair_id = key_pair_id
    @signing_key = OpenSSL::PKey::RSA.new(File.read(private_key_path))
    @expiry_time = expiry_time
  end

  def sign(object_key:, query_string: {})
    subject = "https://#{domain.strip}/#{object_key.strip}?#{build_query(query_string)}"
    expires = Time.now.to_i + @expiry_time
    signature = generate_signature(subject:, expires:)
    build_signed_url(subject:, signature:, expires:)
  end

  private

  def build_query(query_string)
    query_string.map { |key, value| "#{key}=#{value}" }.join('&')
  end

  def generate_signature(subject:, expires:)
    signature = @signing_key.sign(OpenSSL::Digest::SHA1.new,
                                  generate_policy(subject, expires))
    base64_signature = Base64.encode64(signature).gsub(/(\n| )/, '')
    aws_encoded_signature = base64_signature.tr('+=/', '-_~')
    aws_encoded_signature
  end

  def generate_policy(subject, expires)
    JSON.generate({
      "Statement": [
        {
          "Resource": subject,
          "Condition": {
            "DateLessThan": {
              "AWS:EpochTime": expires
            }
          }
        }
      ]
    }).gsub(/(\n| )/, '')
  end

  def build_signed_url(subject:, signature:, expires:)
    "#{subject}&Expires=#{expires}&Signature=#{signature}&Key-Pair-Id=#{@key_pair_id}"
  end
end