from langchain.agents import create_agent
from langchain_urlpipe import UrlpipeToolkit

agent = create_agent("anthropic:claude-sonnet-5", tools=UrlpipeToolkit().get_tools())

result = agent.invoke(
    {"messages": [{"role": "user", "content": "Why is https://example.com slow on mobile?"}]}
)
print(result["messages"][-1].content)
