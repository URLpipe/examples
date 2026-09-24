import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

public class HtmlToMarkdown {
    public static void main(String[] args) throws Exception {
        var request = HttpRequest.newBuilder(URI.create("https://urlpipe.dev/markdown"))
            .header("Authorization", "Bearer " + System.getenv("URLPIPE_API_KEY"))
            .header("Content-Type", "application/json")
            // A sync call can take up to 60 s; HttpClient would otherwise wait forever.
            .timeout(Duration.ofSeconds(90))
            .POST(HttpRequest.BodyPublishers.ofString("""
                {"url": "https://example.com", "sync": true}
                """))
            .build();

        var response = HttpClient.newHttpClient().send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 200) {
            System.err.println("URLpipe answered " + response.statusCode() + ": " + response.body());
            System.exit(1);
        }
        String body = response.body();

        // Plain text: pipe it into a file, a chunker or a prompt.
        System.out.println(body);
    }
}
