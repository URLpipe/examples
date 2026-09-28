from langchain_text_splitters import MarkdownHeaderTextSplitter
from langchain_urlpipe import UrlpipeLoader

docs = UrlpipeLoader(
    ["https://docs.example.com/getting-started", "https://docs.example.com/api/auth"],
    page_options={"block_cookie_banners": True},
).load()

splitter = MarkdownHeaderTextSplitter(headers_to_split_on=[("#", "h1"), ("##", "h2")])
chunks = []
for doc in docs:
    for chunk in splitter.split_text(doc.page_content):
        chunk.metadata.update(doc.metadata)  # keep the source URL on every chunk
        chunks.append(chunk)
