from langchain_ollama import OllamaLLM
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import PydanticOutputParser
from pydantic import BaseModel

'''
Script che estrae informazioni strutturate da una descrizione di missione in un gioco fantasy.
L'utente fornisce una descrizione narrativa e il modello genera un obiettivo della missione in formato JSON.
'''

class QuestGoal(BaseModel):
    destination: str
    required_item: str
    success_condition: str


llm = OllamaLLM(model="llama3.2")

# Parser per output strutturato
parser = PydanticOutputParser(pydantic_object=QuestGoal)


prompt = ChatPromptTemplate.from_messages([
    ("system", """You are an assistant that extracts structured information from quest descriptions in a fantasy game.
                    From each description, identify:
                        - destination: the place the hero needs to reach
                        - required_item: the item needed to complete the quest
                        - success_condition: the condition that marks the quest as completed
                    Return ONLY a valid JSON object with the three specified keys and no additional text."""),
    ("human", "{quest_description}")
])



quest_description = input("Inserisci la descrizione della missione:\n")
#quest_description = "The adventurer must reach the Tower of Thorns carrying the Moonstone and defeat the Shadow Beast."

formatted_prompt  = prompt.invoke({"quest_description": quest_description})

response = llm.invoke(formatted_prompt)

# Mostra i risultati
try:
    quest_goal = QuestGoal.model_validate_json(response)
    print("\n✅ Oggetto Pydantic validato:")
    print(quest_goal)

    print("\n📦 Dump JSON:")
    print(quest_goal.model_dump())
except Exception as e:
    print("\n❌ Errore durante la validazione dell'output:")
    print(e)
    print("\nRisposta grezza del modello:")
    print(response)
