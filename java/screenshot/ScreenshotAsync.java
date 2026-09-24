import com.google.gson.JsonParser;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.util.Base64;

public class ScreenshotAsync {
    static final String API = "https://urlpipe.dev";
    static final HttpClient CLIENT = HttpClient.newHttpClient();

    static HttpResponse<String> send(HttpRequest.Builder builder) throws Exception {
        var request = builder
            .header("Authorization", "Bearer " + System.getenv("URLPIPE_API_KEY"))
            .timeout(Duration.ofSeconds(30))
            .build();
        return CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
    }

    static void fail(String message) {
        System.err.println(message);
        System.exit(1);
    }

    public static void main(String[] args) throws Exception {
        // No "sync": the request is accepted at once and the work carries on without you.
        var accepted = send(HttpRequest.newBuilder(URI.create(API + "/screenshot"))
            .header("Content-Type", "application/json")
            .POST(HttpRequest.BodyPublishers.ofString("""
                {
                  "url": "https://example.com",
                  "page_options": {"block_cookie_banners": true},
                  "report_to": "https://your-app.com/webhooks/urlpipe",
                  "labels": {"customer": "acme"}
                }
                """)));
        if (accepted.statusCode() != 200) {
            fail("URLpipe answered " + accepted.statusCode() + ": " + accepted.body());
        }
        String token = JsonParser.parseString(accepted.body()).getAsJsonObject().get("token").getAsString();
        System.out.println("Accepted " + token);

        // The result is POSTed to report_to when it is ready. Polling by token is the
        // other way to collect it: no endpoint needed, and a backup for the webhook.
        HttpResponse<String> response = null;
        for (int attempt = 0; attempt < 60; attempt++) {
            response = send(HttpRequest.newBuilder(URI.create(API + "/result/" + token)).GET());
            if (response.statusCode() != 202) { // 202 means still processing
                break;
            }
            Thread.sleep(2000);
        }
        switch (response.statusCode()) {
            case 200 -> { }
            case 202 -> fail("Still processing after two minutes; try the token again later.");
            case 422 -> fail("The analysis failed: "
                + JsonParser.parseString(response.body()).getAsJsonObject().get("error").getAsString());
            case 410 -> fail("The result is past the 30-day window; send the request again.");
            default -> fail("URLpipe answered " + response.statusCode() + ": " + response.body());
        }
        String body = response.body();

        byte[] png = Base64.getDecoder().decode(body.strip());
        Files.write(Path.of("screenshot.png"), png);
        System.out.println("Saved screenshot.png (" + png.length + " bytes)");
    }
}
