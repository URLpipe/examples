# Get the rendered HTML of a JavaScript page in C#

Get the rendered HTML of a JavaScript page with HttpClient: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/csharp/rendered-html](https://urlpipe.dev/code/csharp/rendered-html).

## Before you start

Nothing to add from NuGet: `HttpClient` and `System.Text.Json` are part of .NET. Each program below is a whole `Program.cs` for a console project.

```bash
dotnet new console -o RenderedHtml && cd RenderedHtml
export URLPIPE_API_KEY="your_api_key"
# replace Program.cs with a program below, then:
dotnet run
```

## Save the rendered HTML and report its size

`sync = true` keeps the request open until the result is ready. `PostAsJsonAsync` serializes the anonymous object, and the property names go out as written, underscores included. HttpClient does not throw on a 4xx or 5xx, so check `IsSuccessStatusCode`. `body.Length` counts UTF-16 chars; the size on disk is the UTF-8 byte count.

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

A local function keeps the retry rules next to the call, and the exception type is declared after the top-level statements, where C# requires it. `RetryAfter.Delta` is the parsed Retry-After header, and a body that is not JSON (a proxy in front of the API can answer in HTML) leaves every field null.

[`Program.cs`](Program.cs)

```bash
dotnet run
```
