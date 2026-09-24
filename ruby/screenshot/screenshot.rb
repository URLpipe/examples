require "json"
require "net/http"

uri = URI("https://urlpipe.dev/screenshot")
# read_timeout: a sync call can take up to 60 s, Net::HTTP's default.
res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: 90) do |http|
  http.post(uri.path, { url: "https://example.com", page_options: { block_cookie_banners: true }, sync: true }.to_json,
            "Authorization" => "Bearer #{ENV.fetch("URLPIPE_API_KEY")}",
            "Content-Type" => "application/json")
end
abort "URLpipe answered #{res.code}: #{res.body}" unless res.is_a?(Net::HTTPOK)

png = res.body.unpack1("m") # Base64 decode, core Ruby
File.binwrite("screenshot.png", png)
puts "Saved screenshot.png (#{png.bytesize} bytes)"
