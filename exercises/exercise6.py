import os
from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_ollama import OllamaEmbeddings, ChatOllama
from langchain_community.vectorstores import InMemoryVectorStore
from langchain_core.prompts import ChatPromptTemplate

# Caricare il file di lore
def load_lore_file(file_path: str):
    if not os.path.exists(file_path):
        print(f"Errore: Il file '{file_path}' non esiste.")
        exit(1)
    try:
        loader = TextLoader(file_path)
        documents = loader.load()
        return documents
    except Exception as e:
        print(f"Errore nel caricamento del file: {e}")
        exit(1)

# Dividere il testo in frammenti
def split_documents(documents):
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=200,
        chunk_overlap=20,
        separators=["\n\n", "\n", ". ", " "]
    )
    chunks = text_splitter.split_documents(documents)
    if not chunks:
        print("Errore: Nessun frammento generato dal testo.")
        exit(1)
    return chunks

# Creare il vector store con embeddings
def create_vector_store(chunks):
    try:
        embeddings = OllamaEmbeddings(model="llama3.2")
        vector_store = InMemoryVectorStore(embeddings)
        vector_store.add_documents(chunks)
        return vector_store
    except Exception as e:
        print(f"Errore nella creazione del vector store: {e}")
        exit(1)

# Recuperare frammenti rilevanti
def retrieve_chunks(vector_store, keyword: str, k: int = 2):
    retriever = vector_store.as_retriever(
        search_type="similarity",
        search_kwargs={"k": k}
    )
    try:
        relevant_chunks = retriever.invoke(keyword)
        return relevant_chunks
    except Exception as e:
        print(f"Errore nel recupero dei frammenti: {e}")
        return []

# 2) Configurazione RAG per la generazione narrativa -----------------------------
def setup_rag():
    # Inizializza Llama 3.2 con bassa casualità per risposte coerenti
    llm = ChatOllama(model="llama3.2", temperature=0.1, num_predict=512)

    # Crea il prompt template per la narrativa
    prompt_template = ChatPromptTemplate.from_messages(
        [
            (
                "system",
                "You are an expert storyteller who creates narrative quests consistent with the lore of the game world. "
                "Use the provided context to generate a quest description that includes the specified goal and obstacle, "
                "while maintaining consistency with the lore."
            ),
            (
                "user",
                "Context (lore):\n{context}\n\n"
                "Goal: {goal}\n"
                "Obstacle: {obstacle}\n\n"
                "Generate a narrative description for a quest based on the goal and obstacle, "
                "incorporating details from the context."
            ),
        ]

    )
    return llm, prompt_template

# 3) Generazione della narrativa ------------------------------------------------
def generate_narrative(vector_store, goal: str, obstacle: str):
    # Recupera frammenti di lore rilevanti basati sul goal
    relevant_chunks = retrieve_chunks(vector_store, goal)
    if not relevant_chunks:
        return "Nessun frammento di lore trovato per il goal specificato."

    # Unisce i frammenti in un contesto
    context = "\n---\n".join(chunk.page_content for chunk in relevant_chunks)

    # Configura il LLM e il prompt
    llm, prompt_template = setup_rag()

    # Inietta le variabili nel prompt
    formatted_prompt = prompt_template.invoke({
        "context": context,
        "goal": goal,
        "obstacle": obstacle
    })

    # Genera la narrativa
    try:
        response = llm.invoke(formatted_prompt)
        return response.content
    except Exception as e:
        return f"Errore nella generazione della narrativa: {e}"

# 4) Ciclo interattivo principale -----------------------------------------------
def main():
    # Carica e configura il retriever
    file_path = "lore.txt"
    documents = load_lore_file(file_path)
    print(f"Caricato il file '{file_path}' con {len(documents)} documento/i.")
    chunks = split_documents(documents)
    print(f"Generati {len(chunks)} frammenti di lore.")
    vector_store = create_vector_store(chunks)
    print("Vector store creato con successo.")

    # Ciclo interattivo
    print("\n📜 Generatore di missioni narrative")
    print("Inserisci 'exit' o 'quit' per terminare.\n")
    while True:
        goal = input("Inserisci il goal della missione (es. 'rescue the phoenix'): ").strip()
        if goal.lower() in ("exit", "quit"):
            break
        obstacle = input("Inserisci l'ostacolo (es. 'a mountain storm'): ").strip()
        if obstacle.lower() in ("exit", "quit"):
            break

        # Genera e mostra la narrativa
        narrative = generate_narrative(vector_store, goal, obstacle)
        print(f"\n📖 Narrativa della missione:\n{narrative}\n{'='*60}\n")

if __name__ == "__main__":
    main()