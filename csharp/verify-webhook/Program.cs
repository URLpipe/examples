using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

const int ToleranceSeconds = 5 * 60;
var secret = Encoding.UTF8.GetBytes(
    Environment.GetEnvironmentVariable("URLPIPE_WEBHOOK_SECRET")
        ?? throw new InvalidOperationException("Set URLPIPE_WEBHOOK_SECRET"));

var app = WebApplication.Create(args);

app.MapPost("/webhooks/urlpipe", async (HttpRequest request) =>
{
    // The raw bytes, exactly as sent.
    using var buffer = new MemoryStream();
    await request.Body.CopyToAsync(buffer);
    var body = buffer.ToArray();

    var timestamp = request.Headers["X-URLpipe-Timestamp"].ToString();
    var signature = request.Headers["X-URLpipe-Signature"].ToString();
    if (!Verify(body, timestamp, signature)) return Results.Unauthorized();

    using var delivery = JsonDocument.Parse(body);
    app.Logger.LogInformation("Verified delivery for {Token}", delivery.RootElement.GetProperty("token").GetString());
    return Results.Ok();
});

app.Run();

// True when the delivery was signed with the secret in the last five minutes.
bool Verify(byte[] body, string timestamp, string signatureHeader)
{
    if (!long.TryParse(timestamp, out var seconds) ||
        Math.Abs(DateTimeOffset.UtcNow.ToUnixTimeSeconds() - seconds) > ToleranceSeconds)
    {
        return false;
    }

    var signed = Encoding.UTF8.GetBytes($"{timestamp}.").Concat(body).ToArray();
    var expected = Encoding.UTF8.GetBytes("v1=" + Convert.ToHexString(HMACSHA256.HashData(secret, signed)).ToLowerInvariant());

    // One signature normally, two during a secret rotation: accept any match.
    return signatureHeader.Split(',').Any(candidate =>
        CryptographicOperations.FixedTimeEquals(Encoding.UTF8.GetBytes(candidate.Trim()), expected));
}
