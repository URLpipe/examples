<?php

function fail(string $message): never
{
    fwrite(STDERR, $message . "\n");
    exit(1);
}

$ch = curl_init("https://urlpipe.dev/screenshot");
curl_setopt_array($ch, [
    CURLOPT_POST => true,
    // Return the body from curl_exec() instead of printing it.
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        "Authorization: Bearer " . getenv("URLPIPE_API_KEY"),
        "Content-Type: application/json",
    ],
    CURLOPT_POSTFIELDS => json_encode(["url" => "https://example.com", "page_options" => ["block_cookie_banners" => true], "sync" => true]),
    // A sync call can take up to 60 s; curl would otherwise wait forever.
    CURLOPT_TIMEOUT => 90,
]);
$body = curl_exec($ch);
if ($body === false) {
    fail("Request failed: " . curl_error($ch));
}
$status = curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
if ($status !== 200) {
    fail("URLpipe answered {$status}: {$body}");
}

$png = base64_decode($body);
file_put_contents("screenshot.png", $png);
echo "Saved screenshot.png (" . strlen($png) . " bytes)\n";
