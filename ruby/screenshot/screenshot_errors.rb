require "json"
require "net/http"

class URLpipeError < StandardError; end

# POST a sync request and return the response, or raise URLpipeError.
def urlpipe(path, payload, attempts: 5)
  uri = URI("https://urlpipe.dev#{path}")
  attempts.times do |attempt|
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: 90) do |http|
      http.post(uri.path, payload.merge(sync: true).to_json,
                "Authorization" => "Bearer #{ENV.fetch("URLPIPE_API_KEY")}",
                "Content-Type" => "application/json")
    end
    return res if res.code == "200"
    raise URLpipeError, "401: the API key is missing or wrong. Check URLPIPE_API_KEY." if res.code == "401"

    body = begin
      JSON.parse(res.body)
    rescue JSON::ParserError
      {}
    end
    code = body["error"].to_s
    detail = body["message"] ? "#{code}: #{body["message"]}" : code

    case [ res.code, code ]
    in [ "429", "rate_limited" ]
      # Sending too fast: Retry-After says how long the window has left.
      sleep Integer(res["Retry-After"] || 1)
    in [ "429", "concurrency_limit" ]
      # Every parallel slot on your plan is busy with your own requests.
      sleep 2**attempt
    in [ "504", _ ]
      # Still running on our side; the token collects it from GET /result/:token.
      raise URLpipeError, "504 processing_timeout: collect it later with token #{body["token"]}"
    else
      # 403 email_unverified, 422 (a bad parameter, or a page that would not load),
      # 429 quota_exceeded: sending the same request again gets the same answer.
      raise URLpipeError, "#{res.code}: #{detail}"
    end
  end
  raise URLpipeError, "429: still refused after #{attempts} attempts"
end

begin
  res = urlpipe("/screenshot", { url: "https://example.com", page_options: { block_cookie_banners: true } })
rescue URLpipeError => e
  abort "URLpipe: #{e.message}"
end

png = res.body.unpack1("m") # Base64 decode, core Ruby
File.binwrite("screenshot.png", png)
puts "Saved screenshot.png (#{png.bytesize} bytes)"
