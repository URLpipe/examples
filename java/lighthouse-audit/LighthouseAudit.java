import com.google.gson.JsonElement;
import com.google.gson.JsonParser;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;

public class LighthouseAudit {
    public static void main(String[] args) throws Exception {
        var request = HttpRequest.newBuilder(URI.create("https://urlpipe.dev/lighthouse"))
            .header("Authorization", "Bearer " + System.getenv("URLPIPE_API_KEY"))
            .header("Content-Type", "application/json")
            // A sync call can take up to 60 s; HttpClient would otherwise wait forever.
            .timeout(Duration.ofSeconds(90))
            .POST(HttpRequest.BodyPublishers.ofString("""
                {"url": "https://example.com", "device": "mobile", "sync": true}
                """))
            .build();

        var response = HttpClient.newHttpClient().send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 200) {
            System.err.println("URLpipe answered " + response.statusCode() + ": " + response.body());
            System.exit(1);
        }
        String body = response.body();

        JsonElement report = JsonParser.parseString(body);
        for (String name : List.of("performance", "accessibility", "best-practices", "seo")) {
            JsonElement score = dig(report, "categories", name, "score");
            System.out.println(name + ": " + (score == null ? "n/a" : Math.round(score.getAsDouble() * 100)));
        }

        String[][] metrics = {
            {"LCP", "largest-contentful-paint"},
            {"CLS", "cumulative-layout-shift"},
            {"TBT", "total-blocking-time"},
        };
        for (String[] metric : metrics) {
            JsonElement value = dig(report, "metrics", metric[1], "displayValue");
            System.out.println(metric[0] + ": " + (value == null ? "n/a" : value.getAsString()));
        }
    }

    // The value at a path of keys, or null where any step is missing or JSON null.
    static JsonElement dig(JsonElement element, String... keys) {
        for (String key : keys) {
            if (element == null || !element.isJsonObject()) {
                return null;
            }
            element = element.getAsJsonObject().get(key);
        }
        return element == null || element.isJsonNull() ? null : element;
    }
}
