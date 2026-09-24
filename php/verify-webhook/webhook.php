<?php

const TOLERANCE = 5 * 60; // seconds

// True when the delivery was signed with $secret in the last five minutes.
function verify(string $body, string $timestamp, string $signatureHeader, string $secret): bool
{
    if (!ctype_digit($timestamp) || abs(time() - (int) $timestamp) > TOLERANCE) {
        return false;
    }
    $expected = "v1=" . hash_hmac("sha256", "{$timestamp}.{$body}", $secret);
    // One signature normally, two during a secret rotation: accept any match.
    foreach (explode(",", $signatureHeader) as $signature) {
        if (hash_equals($expected, trim($signature))) {
            return true;
        }
    }
    return false;
}

$path = parse_url($_SERVER["REQUEST_URI"], PHP_URL_PATH);
if ($_SERVER["REQUEST_METHOD"] !== "POST" || $path !== "/webhooks/urlpipe") {
    http_response_code(404);
    exit;
}

// The raw bytes, exactly as sent.
$body = file_get_contents("php://input");
$verified = verify(
    $body,
    $_SERVER["HTTP_X_URLPIPE_TIMESTAMP"] ?? "",
    $_SERVER["HTTP_X_URLPIPE_SIGNATURE"] ?? "",
    getenv("URLPIPE_WEBHOOK_SECRET"),
);
if (!$verified) {
    http_response_code(401);
    exit;
}

$delivery = json_decode($body, true);
error_log("Verified delivery for {$delivery["token"]}");
http_response_code(200);
