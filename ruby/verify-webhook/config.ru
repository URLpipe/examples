require "json"
require "openssl"

class UrlpipeWebhook
  TOLERANCE = 5 * 60 # seconds

  def initialize(secret)
    @secret = secret
  end

  def call(env)
    request = Rack::Request.new(env)
    return [ 404, {}, [] ] unless request.post? && request.path == "/webhooks/urlpipe"

    # The raw bytes, exactly as sent.
    body = request.body.read
    timestamp = request.get_header("HTTP_X_URLPIPE_TIMESTAMP").to_s
    signature = request.get_header("HTTP_X_URLPIPE_SIGNATURE").to_s
    return [ 401, {}, [] ] unless verify(body, timestamp, signature)

    delivery = JSON.parse(body)
    warn "Verified delivery for #{delivery["token"]}"
    [ 200, {}, [] ]
  end

  # True when the delivery was signed with the secret in the last five minutes.
  def verify(body, timestamp, signature_header)
    return false unless timestamp.match?(/\A\d+\z/) && (Time.now.to_i - timestamp.to_i).abs <= TOLERANCE

    expected = "v1=" + OpenSSL::HMAC.hexdigest("SHA256", @secret, "#{timestamp}.#{body}")
    # One signature normally, two during a secret rotation: accept any match.
    signature_header.split(",").any? { |signature| OpenSSL.secure_compare(signature.strip, expected) }
  end
end

run UrlpipeWebhook.new(ENV.fetch("URLPIPE_WEBHOOK_SECRET"))
