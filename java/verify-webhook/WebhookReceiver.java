import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.time.Instant;
import java.util.HexFormat;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public class WebhookReceiver {
    static final byte[] SECRET = System.getenv("URLPIPE_WEBHOOK_SECRET").getBytes(StandardCharsets.UTF_8);
    static final long TOLERANCE_SECONDS = 5 * 60;

    // True when the delivery was signed with SECRET in the last five minutes.
    static boolean verify(byte[] body, String timestamp, String signatureHeader) {
        if (timestamp == null || signatureHeader == null || !timestamp.matches("\\d{1,18}")) {
            return false;
        }
        if (Math.abs(Instant.now().getEpochSecond() - Long.parseLong(timestamp)) > TOLERANCE_SECONDS) {
            return false;
        }

        byte[] digest;
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(SECRET, "HmacSHA256"));
            mac.update((timestamp + ".").getBytes(StandardCharsets.UTF_8));
            digest = mac.doFinal(body);
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException(e); // every JDK ships HmacSHA256
        }
        byte[] expected = ("v1=" + HexFormat.of().formatHex(digest)).getBytes(StandardCharsets.UTF_8);

        // One signature normally, two during a secret rotation: accept any match.
        for (String signature : signatureHeader.split(",")) {
            if (MessageDigest.isEqual(signature.strip().getBytes(StandardCharsets.UTF_8), expected)) {
                return true;
            }
        }
        return false;
    }

    static void handle(HttpExchange exchange) throws IOException {
        try {
            if (!exchange.getRequestMethod().equals("POST")) {
                exchange.sendResponseHeaders(405, -1);
                return;
            }
            // The raw bytes, exactly as sent.
            byte[] body = exchange.getRequestBody().readAllBytes();
            var headers = exchange.getRequestHeaders();
            if (!verify(body, headers.getFirst("X-URLpipe-Timestamp"), headers.getFirst("X-URLpipe-Signature"))) {
                exchange.sendResponseHeaders(401, -1);
                return;
            }

            // Verified: hand the body to your JSON library and queue the work.
            System.out.println("Verified delivery (" + body.length + " bytes)");
            exchange.sendResponseHeaders(200, -1);
        } finally {
            exchange.close();
        }
    }

    public static void main(String[] args) throws IOException {
        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8000"));
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        server.createContext("/webhooks/urlpipe", WebhookReceiver::handle);
        server.start();
    }
}
