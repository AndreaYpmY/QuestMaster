"""
Semantic Search + RAG with Ollama (llama3.2) & LangChain

This updated script:
• Fixes deprecated imports by using dedicated community & Ollama packages
• Uses the modern Retriever.invoke() interface
• Includes inline comments to guide students through each step

Pre-requisites:
• Install updated packages:
    pip install langchain langchain-community langchain-ollama langchain-text-splitters pypdf langchain-huggingface sentence-transformers
"""

import os

# Use the community loader for PDFs
from langchain_community.document_loaders import PyPDFLoader

# Text splitter for creating overlapping chunks
from langchain_text_splitters import RecursiveCharacterTextSplitter

# 1) Document loading & splitting ------------------------------------------------


PDF_PATH = "lore.pdf"
if not os.path.exists(PDF_PATH):
    raise FileNotFoundError(f"Unable to find PDF at {PDF_PATH}")

# Load each page as a Document object
loader = PyPDFLoader(PDF_PATH)
docs = loader.load()
print(f"✅ Loaded {len(docs)} pages from PDF.")

# Split pages into ~1000‐char chunks with 200‐char overlap
splitter = RecursiveCharacterTextSplitter(
    chunk_size=500,
    chunk_overlap=50,
    add_start_index=True,  # preserve original page offset in metadata
)
chunks = splitter.split_documents(docs)
print(f"✅ Split into {len(chunks)} text chunks.")


# 2) Embeddings & Vector Store ---------------------------------------------------
from langchain_core.vectorstores import InMemoryVectorStore

# Use the HuggingFace-backed embeddings (replacement for deprecated import)
# You may also install "langchain-huggingface" for the latest class
from langchain_huggingface import HuggingFaceEmbeddings

# Initialize embeddings model (runs locally)
embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")

# Create an in-memory vector store and index the chunks
vector_store = InMemoryVectorStore(embeddings)
ids = vector_store.add_documents(chunks)
print(f"✅ Indexed {len(ids)} chunks into vector store.")

# 3) Retrieval setup -------------------------------------------------------------
# Convert the vector store into a Retriever (default similarity search)
retriever = vector_store.as_retriever(search_kwargs={"k": 2})

# 4) RAG: Query + Ollama Answering -----------------------------------------------

from langchain_core.prompts import ChatPromptTemplate
from langchain_ollama import ChatOllama

# Initialize llama3.2 with low randomness for factual answers
llm = ChatOllama(model="llama3.2", temperature=0.1, num_predict=512)

# Build a prompt template that injects the retrieved context
prompt_template = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a knowledgeable assistant. Use the provided context to answer the question with the most similar chunks.",
        ),
        ("user", "Context:\n{context}\n\nQuestion: {question}"),
    ]
)


def answer_query(query: str) -> str:
    """
    1) Retrieve top-k chunks for the query via invoke()
    2) Concatenate their content into a context block
    3) Format the prompt and invoke the LLM for an answer
    """
    # Retrieve documents (modern invoke interface)
    docs = retriever.invoke(query)
    # Join chunk texts with separators for clarity
    context = "\n---\n".join(d.page_content for d in docs)
    # Fill in the prompt template
    formatted = prompt_template.invoke({"context": context, "question": query})
    # Call the LLM and return the assistant's reply
    response = llm.invoke(formatted)
    return response.content


# 5) Interactive loop ------------------------------------------------------------


def main():
    print("\n🔎 Semantic Search + Ollama (llama3.2) RAG Demo")
    print("Type 'exit' or 'quit' to end.\n")
    while True:
        q = input("Your question: ").strip()
        if q.lower() in ("exit", "quit"):
            break
        answer = answer_query(q)
        print(f"\n🤖 Answer:\n{answer}\n{'='*60}\n")


if __name__ == "__main__":
    main()
