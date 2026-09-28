import asyncio
from llama_index.readers.urlpipe import UrlpipeReader

async def main(urls: list[str]) -> None:
    reader = UrlpipeReader(max_concurrency=8, continue_on_failure=True)
    documents = await reader.aload_data(urls)
    print(len(documents), "pages loaded")

asyncio.run(main(["https://docs.example.com/a", "https://docs.example.com/b"]))
