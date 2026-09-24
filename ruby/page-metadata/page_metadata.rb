require "json"
require "net/http"

uri = URI("https://urlpipe.dev/meta")
# read_timeout: a sync call can take up to 60 s, Net::HTTP's default.
res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: 90) do |http|
  http.post(uri.path, { url: "https://example.com", sync: true }.to_json,
            "Authorization" => "Bearer #{ENV.fetch("URLPIPE_API_KEY")}",
            "Content-Type" => "application/json")
end
abort "URLpipe answered #{res.code}: #{res.body}" unless res.is_a?(Net::HTTPOK)

meta = JSON.parse(res.body)
puts "Title: #{meta["title"] || "none"}"
puts "Description: #{meta["description"] || "none"}"
puts "Image: #{meta["main_image_url"] || "none"}"
