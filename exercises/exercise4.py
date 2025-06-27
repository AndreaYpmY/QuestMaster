import json
from langchain_ollama import OllamaLLM
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.output_parsers import PydanticOutputParser
from pydantic import BaseModel
from typing import List


class PDDLAction(BaseModel):
    name: str
    parameters: List[str]
    preconditions: List[str]
    effects: List[str]

# Esempi per few-shot learning
examples = [
    {
        "input": "The knight unlocks the door using a golden key.",
        "output": {
            "name": "unlock-door",
            "parameters": ["?k - knight", "?d - door", "?key - key"],
            "preconditions": ["(has ?k ?key)", "(locked ?d)", "(fits ?key ?d)"],
            "effects": ["(unlocked ?d)", "(not (locked ?d))"]
        }
    },
    {
        "input": "A hero climbs a ladder to reach a tower.",
        "output": {
            "name": "climb-ladder",
            "parameters": ["?h - hero", "?l - ladder", "?t - tower"],
            "preconditions": ["(at ?h bottom)", "(connected ?l ?t)"],
            "effects": ["(at ?h top)", "(not (at ?h bottom))"]
        }
    }
]

llm = OllamaLLM(model="llama3.2", temperature=0.0)

# Parser per output strutturato
parser = PydanticOutputParser(pydantic_object=PDDLAction)


example_messages = [
    [
        ("user", ex["input"]),
        ("assistant", json.dumps(ex["output"]))
    ]
    for ex in examples
]

prompt = ChatPromptTemplate.from_messages([
    ("system", f"""You are an expert in PDDL (Planning Domain Definition Language). 
Y               Our task is to extract structured PDDL action definitions from natural language descriptions.
                Return ONLY a valid JSON object (no explanations, no comments, no Python code), matching exactly this schema:
                {parser.get_format_instructions().replace('{', '{{').replace('}', '}}')}"""),
    MessagesPlaceholder(variable_name="examples"),
    ("human", "{action_description}")
])

def render_pddl_action(action: PDDLAction) -> str:
    """Converte un PDDLAction in sintassi PDDL valida"""
    pddl = f"(:action {action.name}\n"
    pddl += f"  :parameters ({' '.join(action.parameters)})\n"
    
    if action.preconditions:
        if len(action.preconditions) == 1:
            pddl += f"  :precondition {action.preconditions[0]}\n"
        else:
            pddl += f"  :precondition (and\n"
            for prec in action.preconditions:
                pddl += f"    {prec}\n"
            pddl += f"  )\n"
    
    if action.effects:
        if len(action.effects) == 1:
            pddl += f"  :effect {action.effects[0]}\n"
        else:
            pddl += f"  :effect (and\n"
            for eff in action.effects:
                pddl += f"    {eff}\n"
            pddl += f"  )\n"
    
    pddl += ")"
    return pddl

# Input dell'utente
action_description = input("Inserisci la descrizione dell'azione: ")

# Genera il prompt formattato
formatted_prompt = prompt.invoke({"examples": [msg for example in example_messages for msg in example],
                                                "action_description": action_description})

# Ottieni la risposta dal modello
response = llm.invoke(formatted_prompt)

# Mostra i risultati
try:
    # Prova a validare l'output
    pddl_action = parser.parse(response)
    
    print("\n✅ PDDLAction estratta con successo:")
    print(f"Nome: {pddl_action.name}")
    print(f"Parametri: {pddl_action.parameters}")
    print(f"Precondizioni: {pddl_action.preconditions}")
    print(f"Effetti: {pddl_action.effects}")
    
    
    print("\n🎯 Sintassi PDDL:")
    print(render_pddl_action(pddl_action))
    
except Exception as e:
    print("\n❌ Errore durante la validazione dell'output:")
    print(f"Errore: {e}")
    print("\nRisposta grezza del modello:")
    print(response)