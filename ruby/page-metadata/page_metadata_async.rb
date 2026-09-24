require "json"
require "net/http"

API = URI("https://urlpipe.dev")

def send_request(request)
  request["Authorization"] = "Bearer #{ENV.fetch("URLPIPE_API_KEY")}"
  Net::HTTP.start(API.host, API.port, use_ssl: API.scheme == "https") { |http| http.request(request) }
end

# No sync: the request is accepted at once and the work carries on without you.
post = Net::HTTP::Post.new(URI.join(API, "/meta"), "Content-Type" => "application/json")
post.body = {
  url: "https://example.com",
  report_to: "https://your-app.com/webhooks/urlpipe",
  labels: { customer: "acme" }
}.to_json
res = send_request(post)
abort "URLpipe answered #{res.code}: #{res.body}" unless res.is_a?(Net::HTTPOK)
token = JSON.parse(res.body).fetch("token")
puts "Accepted #{token}"

# The result is POSTed to report_to when it is ready. Polling by token is the
# other way to collect it: no endpoint needed, and a backup for the webhook.
60.times do
  res = send_request(Net::HTTP::Get.new(URI.join(API, "/result/#{token}")))
  break unless res.code == "202" # 202 means still processing

  sleep 2
end

case res.code
when "200" then nil
when "202" then abort "Still processing after two minutes; try the token again later."
when "422" then abort "The analysis failed: #{JSON.parse(res.body)["error"]}"
when "410" then abort "The result is past the 30-day window; send the request again."
else abort "URLpipe answered #{res.code}: #{res.body}"
end

meta = JSON.parse(res.body)
puts "Title: #{meta["title"] || "none"}"
puts "Description: #{meta["description"] || "none"}"
puts "Image: #{meta["main_image_url"] || "none"}"
