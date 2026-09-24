import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

public class HtmlToMarkdownErrors {
    static class URLpipeException extends Exception {
        URLpipeException(String message) {
            super(message);
        }
    }

    static final HttpClient CLIENT = HttpClient.newHttpClient();

    // POST a sync request and return the result body; retry the two 429s that clear by themselves.
    static String urlpipe(String path, String payload) throws Exception {
        final int attempts = 5;
        for (int attempt = 0; attempt < attempts; attempt++) {
            var request = HttpRequest.newBuilder(URI.create("https://urlpipe.dev" + path))
                .header("Authorization", "Bearer " + System.getenv("URLPIPE_API_KEY"))
                .header("Content-Type", "application/json")
                .timeout(Duration.ofSeconds(90))
                .POST(HttpRequest.BodyPublishers.ofString(payload))
                .build();
            var response = CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
            int status = response.statusCode();
            if (status == 200) {
                return response.body();
            }
            if (status == 401) {
                throw new URLpipeException("401: the API key is missing or wrong. Check URLPIPE_API_KEY.");
            }

            JsonObject error;
            try {
                error = JsonParser.parseString(response.body()).getAsJsonObject();
            } catch (RuntimeException notJson) {
                error = new JsonObject();
            }
            String code = error.has("error") ? error.get("error").getAsString() : "";
            String detail = error.has("message") ? code + ": " + error.get("message").getAsString() : code;

            if (status == 429 && code.equals("rate_limited")) {
                // Sending too fast: Retry-After says how long the window has left.
                Thread.sleep(response.headers().firstValueAsLong("Retry-After").orElse(1) * 1000);
            } else if (status == 429 && code.equals("concurrency_limit")) {
                // Every parallel slot on your plan is busy with your own requests.
                Thread.sleep((1L << attempt) * 1000);
            } else if (status == 504) {
                // Still running on our side; the token collects it from GET /result/:token.
                throw new URLpipeException(
                    "504 processing_timeout: collect it later with token " + error.get("token").getAsString());
            } else {
                // 403 email_unverified, 422 (a bad parameter, or a page that would not load),
                // 429 quota_exceeded: sending the same request again gets the same answer.
                throw new URLpipeException(status + ": " + detail);
            }
        }
        throw new URLpipeException("429: still refused after " + attempts + " attempts");
    }

    public static void main(String[] args) throws Exception {
        String body;
        try {
            body = urlpipe("/markdown", """
                {"url": "https://example.com", "sync": true}
                """);
        } catch (URLpipeException e) {
            System.err.println("URLpipe: " + e.getMessage());
            System.exit(1);
            return;
        }

        // Plain text: pipe it into a file, a chunker or a prompt.
        System.out.println(body);
    }
}
