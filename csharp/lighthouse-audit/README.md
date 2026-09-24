# Run a Lighthouse audit in C#

Run a Lighthouse audit with HttpClient: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/csharp/lighthouse-audit](https://urlpipe.dev/code/csharp/lighthouse-audit).

## Before you start

Nothing to add from NuGet: `HttpClient` and `System.Text.Json` are part of .NET. Each program below is a whole `Program.cs` for a console project.

```bash
dotnet new console -o LighthouseAudit && cd LighthouseAudit
export URLPIPE_API_KEY="your_api_key"
# replace Program.cs with a program below, then:
dotnet run
```

## Print the four scores, LCP, CLS and TBT

`sync = true` keeps the request open until the result is ready. `PostAsJsonAsync` serializes the anonymous object, and the property names go out as written, underscores included. HttpClient does not throw on a 4xx or 5xx, so check `IsSuccessStatusCode`. `?.` carries a category or metric that came back `null` through to "n/a" instead of throwing.

[`Program.cs`](Program.cs)

```bash
dotnet run
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. `JsonNode` reads one field without declaring a class for the response, and `Task.Delay` waits between polls without holding a thread.

[`Program.cs`](Program.cs)

```bash
dotnet run
```

## Handle errors and retries

A local function keeps the retry rules next to the call, and the exception type is declared after the top-level statements, where C# requires it. `RetryAfter.Delta` is the parsed Retry-After header, and a body that is not JSON (a 401 answers in plain text) leaves every field null.

[`Program.cs`](Program.cs)

```bash
dotnet run
```
