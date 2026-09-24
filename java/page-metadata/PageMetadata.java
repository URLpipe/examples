import com.google.gson.JsonElement;
import com.google.gson.JsonParser;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

public class PageMetadata {
    public static void main(String[] args) throws Exception {
        var request = HttpRequest.newBuilder(URI.create("https://urlpipe.dev/meta"))
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

        JsonElement meta = JsonParser.parseString(body);
        String[][] fields = {{"Title", "title"}, {"Description", "description"}, {"Image", "main_image_url"}};
        for (String[] field : fields) {
            JsonElement value = dig(meta, field[1]);
            System.out.println(field[0] + ": " + (value == null ? "none" : value.getAsString()));
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
