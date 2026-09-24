<?php

function fail(string $message): never
{
    fwrite(STDERR, $message . "\n");
    exit(1);
}

$ch = curl_init("https://urlpipe.dev/lighthouse");
curl_setopt_array($ch, [
    CURLOPT_POST => true,
    // Return the body from curl_exec() instead of printing it.
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        "Authorization: Bearer " . getenv("URLPIPE_API_KEY"),
        "Content-Type: application/json",
    ],
    CURLOPT_POSTFIELDS => json_encode(["url" => "https://example.com", "device" => "mobile", "sync" => true]),
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

$report = json_decode($body, true);
foreach (["performance", "accessibility", "best-practices", "seo"] as $name) {
    $score = $report["categories"][$name]["score"] ?? null;
    echo "{$name}: " . ($score === null ? "n/a" : round($score * 100)) . "\n";
}

$metrics = [
    "LCP" => "largest-contentful-paint",
    "CLS" => "cumulative-layout-shift",
    "TBT" => "total-blocking-time",
];
foreach ($metrics as $label => $key) {
    echo "{$label}: " . ($report["metrics"][$key]["displayValue"] ?? "n/a") . "\n";
}
