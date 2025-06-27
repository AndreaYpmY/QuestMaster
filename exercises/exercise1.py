from langchain_ollama import OllamaLLM
from langchain_core.prompts import ChatPromptTemplate

'''
Script per generare una descrizione narrativa di una missione in un gioco di ruolo fantasy.
L'utente specifica un obiettivo e un ostacolo, e il modello genera una narrazione
immersiva in stile fantasy. 
'''

# Inizializzazione del modello LLaMA 3.2
llm = OllamaLLM(model="llama3.2")

# Prompt in inglese, breve e specifico
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a game designer assistant. Generate a narrative-style text that describes a quest in a fantasy game. Do not use a list format"),
    ("user", "Create a quest where the goal is {goal} and the obstacle is {obstacle}")
])

def create_quest(goal: str, obstacle: str) -> str:
    formatted = prompt.invoke({
        "goal": goal, 
        "obstacle": obstacle
    })
    response = llm.invoke(formatted)
    return response


goal = input("Inserisci l'obiettivo della missione: ")
obstacle = input("Inserisci l'ostacolo della missione: ")

quest = create_quest(goal, obstacle)
print(f"Quest: {quest}")
