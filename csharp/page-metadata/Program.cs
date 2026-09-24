using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Nodes;

using var client = new HttpClient { Timeout = TimeSpan.FromSeconds(90) };
client.DefaultRequestHeaders.Authorization =
    new AuthenticationHeaderValue("Bearer", Environment.GetEnvironmentVariable("URLPIPE_API_KEY"));

string body;
try
{
    body = await Urlpipe("/meta", new { url = "https://example.com", sync = true });
}
catch (URLpipeException e)
{
    Console.Error.WriteLine($"URLpipe: {e.Message}");
    return 1;
}

var meta = JsonNode.Parse(body)!;
Console.WriteLine($"Title: {meta["title"]?.GetValue<string>() ?? "none"}");
Console.WriteLine($"Description: {meta["description"]?.GetValue<string>() ?? "none"}");
Console.WriteLine($"Image: {meta["main_image_url"]?.GetValue<string>() ?? "none"}");
return 0;

// POST a sync request and return the result body; retry the two 429s that clear by themselves.
async Task<string> Urlpipe(string path, object payload, int attempts = 5)
{
    for (var attempt = 0; attempt < attempts; attempt++)
    {
        using var response = await client.PostAsJsonAsync($"https://urlpipe.dev{path}", payload);
        var text = await response.Content.ReadAsStringAsync();
        var status = (int)response.StatusCode;
        if (status == 200) return text;
        if (status == 401) throw new URLpipeException("401: the API key is missing or wrong. Check URLPIPE_API_KEY.");

        JsonNode? error = null;
        try { error = JsonNode.Parse(text); } catch (JsonException) { } // not JSON: no fields
        var code = error?["error"]?.GetValue<string>() ?? "";
        var message = error?["message"]?.GetValue<string>();
        var detail = message is null ? code : $"{code}: {message}";

        if (status == 429 && code == "rate_limited")
            // Sending too fast: Retry-After says how long the window has left.
            await Task.Delay(response.Headers.RetryAfter?.Delta ?? TimeSpan.FromSeconds(1));
        else if (status == 429 && code == "concurrency_limit")
            // Every parallel slot on your plan is busy with your own requests.
            await Task.Delay(TimeSpan.FromSeconds(Math.Pow(2, attempt)));
        else if (status == 504)
            // Still running on our side; the token collects it from GET /result/:token.
            throw new URLpipeException($"504 processing_timeout: collect it later with token {error?["token"]?.GetValue<string>()}");
        else
            // 403 email_unverified, 422 (a bad parameter, or a page that would not load),
            // 429 quota_exceeded: sending the same request again gets the same answer.
            throw new URLpipeException($"{status}: {detail}");
    }
    throw new URLpipeException($"429: still refused after {attempts} attempts");
}

class URLpipeException(string message) : Exception(message) { }
