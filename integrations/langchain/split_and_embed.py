from langchain_text_splitters import MarkdownHeaderTextSplitter

docs = URLpipeLoader([
    "https://docs.example.com/getting-started",
    "https://docs.example.com/api/authentication",
]).load()

splitter = MarkdownHeaderTextSplitter(
    headers_to_split_on=[("#", "h1"), ("##", "h2"), ("###", "h3")]
)
chunks = [
    chunk
    for doc in docs
    for chunk in splitter.split_text(doc.page_content)
]
# add doc.metadata["source"] to each chunk's metadata, then hand them to your vector store
