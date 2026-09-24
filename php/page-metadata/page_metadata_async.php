<?php

const API = "https://urlpipe.dev";

function fail(string $message): never
{
    fwrite(STDERR, $message . "\n");
    exit(1);
}

// One request to the API: returns [status, body].
function send(string $method, string $path, ?array $payload = null): array
{
    $ch = curl_init(API . $path);
    curl_setopt_array($ch, [
        CURLOPT_CUSTOMREQUEST => $method,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => [
            "Authorization: Bearer " . getenv("URLPIPE_API_KEY"),
            "Content-Type: application/json",
        ],
        CURLOPT_TIMEOUT => 30,
    ]);
    if ($payload !== null) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
    }
    $body = curl_exec($ch);
    if ($body === false) {
        fail("Request failed: " . curl_error($ch));
    }
    return [curl_getinfo($ch, CURLINFO_RESPONSE_CODE), $body];
}

// No "sync": the request is accepted at once and the work carries on without you.
[$status, $body] = send("POST", "/meta", [
    "url" => "https://example.com",
    "report_to" => "https://your-app.com/webhooks/urlpipe",
    "labels" => ["customer" => "acme"],
]);
if ($status !== 200) {
    fail("URLpipe answered {$status}: {$body}");
}
$token = json_decode($body, true)["token"];
echo "Accepted {$token}\n";

// The result is POSTed to report_to when it is ready. Polling by token is the
// other way to collect it: no endpoint needed, and a backup for the webhook.
for ($attempt = 0; $attempt < 60; $attempt++) {
    [$status, $body] = send("GET", "/result/{$token}");
    if ($status !== 202) { // 202 means still processing
        break;
    }
    sleep(2);
}
if ($status === 202) {
    fail("Still processing after two minutes; try the token again later.");
}
if ($status === 422) {
    fail("The analysis failed: " . json_decode($body, true)["error"]);
}
if ($status === 410) {
    fail("The result is past the 30-day window; send the request again.");
}
if ($status !== 200) {
    fail("URLpipe answered {$status}: {$body}");
}

$meta = json_decode($body, true);
echo "Title: " . ($meta["title"] ?? "none") . "\n";
echo "Description: " . ($meta["description"] ?? "none") . "\n";
echo "Image: " . ($meta["main_image_url"] ?? "none") . "\n";
