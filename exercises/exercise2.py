from langchain_ollama import OllamaLLM
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

'''
Script che genera un'azione PDDL basata su un'azione in un contesto fantasy.
L'utente fornisce una descrizione narrativa e il modello genera un'azione PDDL valida.
Esempi di few-shot sono inclusi per guidare il modello nella generazione di azioni PDDL.
'''


llm = OllamaLLM(model="llama3.2")

# Esempi few-shot per guidare il modello
examples = [
    {
        "input": "A hero climbs a ladder to reach a tower.",
        "output": "(:action climb-ladder :parameters (?h - hero ?l - ladder ?t - tower)  :precondition (and (at ?h bottom) (connected ?l ?t)) :effect (and (at ?h top) (not (at ?h bottom))) )"
    },
    {
        "input": "A hero unlocks a treasure chest with a key.",
        "output": "(:action unlock-chest :parameters (?h - hero ?c - chest ?k - key ?l - location) :precondition (and (at ?h ?l) (at ?c ?l) (has ?h ?k) (locked ?c)) :effect (and (not (locked ?c)) (unlocked ?c)))"
    }
]

# Converte ogni esempio in una lista di messaggi 
example_messages = [
    [
        ("user", ex["input"]),
        ("assistant", ex["output"])
    ]
    for ex in examples
]

# Crea il prompt con MessagesPlaceholder
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are an expert in PDDL. Generate a valid PDDL action based on the narrative description provided in a fantasy context."),
    MessagesPlaceholder(variable_name="examples"),  # Placeholder per gli esempi
    ("user", "{input}")
])


# Funzione per generare un'azione PDDL basata su una descrizione narrativa
def generate_pddl_action(description: str) -> str:

    formatted_prompt = prompt.invoke({
        "examples": [msg for example in example_messages for msg in example], 
        "input": description
    })
    
    response = llm.invoke(formatted_prompt)
    
    return response


# Esempio di utilizzo
input_text = input("Inserisci la descrizione narrativa per l'azione PDDL: ")
action = generate_pddl_action(input_text)
print(f"Azione PDDL generata:\n{action}")

