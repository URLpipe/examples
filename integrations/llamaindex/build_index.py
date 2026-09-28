from llama_index.core import VectorStoreIndex
from llama_index.core.node_parser import MarkdownNodeParser
from llama_index.readers.urlpipe import UrlpipeReader

documents = UrlpipeReader().load_data([
    "https://docs.example.com/getting-started",
    "https://docs.example.com/api/auth",
])

index = VectorStoreIndex.from_documents(documents, transformations=[MarkdownNodeParser()])
print(index.as_query_engine().query("How do I authenticate?"))
