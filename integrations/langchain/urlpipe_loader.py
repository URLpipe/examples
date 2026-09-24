import os
from typing import Iterator

import requests
from langchain_core.document_loaders import BaseLoader
from langchain_core.documents import Document


class URLpipeLoader(BaseLoader):
    """Load web pages as Markdown Documents through URLpipe's /markdown endpoint."""

    def __init__(self, urls: list[str], api_key: str | None = None, max_age: str | int = "7 days"):
        self.urls = urls
        self.max_age = max_age
        self.headers = {"Authorization": f"Bearer {api_key or os.environ['URLPIPE_API_KEY']}"}

    def lazy_load(self) -> Iterator[Document]:
        for url in self.urls:
            res = requests.post("https://urlpipe.dev/markdown", headers=self.headers, timeout=75,
                                json={"url": url, "sync": True, "max_age": self.max_age})
            res.raise_for_status()
            yield Document(page_content=res.text,
                           metadata={"source": url, "cache": res.headers.get("X-Cache")})
