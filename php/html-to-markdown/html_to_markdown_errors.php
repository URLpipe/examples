<?php

final class URLpipeError extends RuntimeException
{
}

// POST a sync request and return the result body, or throw URLpipeError.
function urlpipe(string $path, array $payload, int $attempts = 5): string
{
    for ($attempt = 0; $attempt < $attempts; $attempt++) {
        $headers = [];
        $ch = curl_init("https://urlpipe.dev{$path}");
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                "Authorization: Bearer " . getenv("URLPIPE_API_KEY"),
                "Content-Type: application/json",
            ],
            CURLOPT_POSTFIELDS => json_encode($payload + ["sync" => true]),
            CURLOPT_TIMEOUT => 90,
            // Collect the response headers: Retry-After is the one needed here.
            CURLOPT_HEADERFUNCTION => function ($ch, string $line) use (&$headers): int {
                [$name, $value] = array_pad(explode(":", $line, 2), 2, "");
                $headers[strtolower(trim($name))] = trim($value);
                return strlen($line);
            },
        ]);
        $body = curl_exec($ch);
        if ($body === false) {
            throw new URLpipeError("network error: " . curl_error($ch));
        }
        $status = curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
        if ($status === 200) {
            return $body;
        }
        if ($status === 401) {
            throw new URLpipeError("401: the API key is missing or wrong. Check URLPIPE_API_KEY.");
        }

        $error = json_decode($body, true) ?: [];
        $code = $error["error"] ?? "";
        $detail = isset($error["message"]) ? "{$code}: {$error["message"]}" : $code;

        if ($status === 429 && $code === "rate_limited") {
            // Sending too fast: Retry-After says how long the window has left.
            sleep((int) ($headers["retry-after"] ?? 1));
        } elseif ($status === 429 && $code === "concurrency_limit") {
            // Every parallel slot on your plan is busy with your own requests.
            sleep(2 ** $attempt);
        } elseif ($status === 504) {
            // Still running on our side; the token collects it from GET /result/:token.
            throw new URLpipeError("504 processing_timeout: collect it later with token {$error["token"]}");
        } else {
            // 403 email_unverified, 422 (a bad parameter, or a page that would not load),
            // 429 quota_exceeded: sending the same request again gets the same answer.
            throw new URLpipeError("{$status}: {$detail}");
        }
    }
    throw new URLpipeError("429: still refused after {$attempts} attempts");
}

try {
    $body = urlpipe("/markdown", ["url" => "https://example.com"]);
} catch (URLpipeError $e) {
    fwrite(STDERR, "URLpipe: {$e->getMessage()}\n");
    exit(1);
}

// Plain text: pipe it into a file, a chunker or a prompt.
echo $body, "\n";
