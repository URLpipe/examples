require "json"
require "net/http"

uri = URI("https://urlpipe.dev/lighthouse")
# read_timeout: a sync call can take up to 60 s, Net::HTTP's default.
res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: 90) do |http|
  http.post(uri.path, { url: "https://example.com", device: "mobile", sync: true }.to_json,
            "Authorization" => "Bearer #{ENV.fetch("URLPIPE_API_KEY")}",
            "Content-Type" => "application/json")
end
abort "URLpipe answered #{res.code}: #{res.body}" unless res.is_a?(Net::HTTPOK)

report = JSON.parse(res.body)
%w[performance accessibility best-practices seo].each do |name|
  score = report.dig("categories", name, "score")
  puts "#{name}: #{score ? (score * 100).round : "n/a"}"
end

{
  "LCP" => "largest-contentful-paint",
  "CLS" => "cumulative-layout-shift",
  "TBT" => "total-blocking-time"
}.each do |label, key|
  puts "#{label}: #{report.dig("metrics", key, "displayValue") || "n/a"}"
end
