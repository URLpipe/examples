import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.util.Base64;

public class Screenshot {
    public static void main(String[] args) throws Exception {
        var request = HttpRequest.newBuilder(URI.create("https://urlpipe.dev/screenshot"))
            .header("Authorization", "Bearer " + System.getenv("URLPIPE_API_KEY"))
            .header("Content-Type", "application/json")
            // A sync call can take up to 60 s; HttpClient would otherwise wait forever.
            .timeout(Duration.ofSeconds(90))
            .POST(HttpRequest.BodyPublishers.ofString("""
                {"url": "https://example.com", "page_options": {"block_cookie_banners": true}, "sync": true}
                """))
            .build();

        var response = HttpClient.newHttpClient().send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 200) {
            System.err.println("URLpipe answered " + response.statusCode() + ": " + response.body());
            System.exit(1);
        }
        String body = response.body();

        byte[] png = Base64.getDecoder().decode(body.strip());
        Files.write(Path.of("screenshot.png"), png);
        System.out.println("Saved screenshot.png (" + png.length + " bytes)");
    }
}
