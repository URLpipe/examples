import os

import requests
from llama_index.core import Document
from llama_index.core.readers.base import BaseReader


class URLpipeReader(BaseReader):
    """Read web pages as Markdown through URLpipe's /markdown endpoint."""

    def __init__(self, api_key: str | None = None, max_age: str | int = "7 days"):
        self.max_age = max_age
        self.headers = {"Authorization": f"Bearer {api_key or os.environ['URLPIPE_API_KEY']}"}

    def load_data(self, urls: list[str]) -> list[Document]:
        documents = []
        for url in urls:
            res = requests.post("https://urlpipe.dev/markdown", headers=self.headers, timeout=75,
                                json={"url": url, "sync": True, "max_age": self.max_age})
            res.raise_for_status()
            documents.append(Document(text=res.text, metadata={"source": url}))
        return documents
