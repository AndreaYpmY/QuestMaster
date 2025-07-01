#Progetto QuestMaster

import subprocess
import tempfile
import os

from typing import Annotated, List, Optional
from langchain_ollama import ChatOllama
from langchain_core.prompts import ChatPromptTemplate

from langgraph.graph import (StateGraph, START, END)
from langgraph.graph.message import add_messages
from langgraph.prebuilt import ToolNode, tools_condition
from langgraph.types import Command, interrupt
from typing_extensions import TypedDict
from langchain.agents import AgentExecutor
from langchain.tools import BaseTool


llm = ChatOllama(model="llama3.2")


class QuestMasterState(TypedDict):
    """Schema for data flowing through the graph."""

    file_path: str
    lore: str
    domain_pddl: str
    problem_pddl: str


def CaricaLore_node(state: QuestMasterState):
    with open(state["file_path"], 'r') as f:
            print("Lore document aperto con successo \n")
            content = f.read()
    return {"lore": content}


#Genera un file PDDL dal documento di lore
def GeneraPDDL_node(state: QuestMasterState):
    prompt = ChatPromptTemplate.from_messages([("system", f"""You are a skilled PDDL domain and problem generator.
                Generate a complete PDDL domain and problem text representing the story. Each line of PDDL code should be followed by a comment explaining what the line does.
                Return the domain first, then the problem, separated clearly by a line "---PROBLEM---".Example comment style: ; This line declares the predicate 'at'---""" ), 
                ("user", "Given the following Lore Document describing a quest: {lore_text}")])
    
    formatted_prompt = prompt.invoke({"lore_text": state["lore"]})
    response_llm = llm.invoke(formatted_prompt)
    response = response_llm.content

    print("LLM per generare il PDDL invocato")

    try:
        # Splitta domain e problem PDDL
        if "---PROBLEM---" in response:
            domain_pddl, problem_pddl = response.split("---PROBLEM---", 1)
            print("Domain: ", domain_pddl)
            print("Problem:", problem_pddl)
        else:
            # fallback
            raise Exception("Splitting non avvenuto con successo. ---Problem--- non era presente")
        return {"domain_pddl": domain_pddl.strip(), "problem_pddl": problem_pddl.strip()}
    except Exception as e:
        return f"Errore nella generazione della narrativa: {e}"


"""
# --- Tool: PDDL Validator ---
class ValidatePDDLTool(BaseTool):
    name = "validate_pddl"
    description = "Valida i file PDDL usando Fast Downward"

    def _run(self, inputs):
        domain_file = inputs["domain_pddl"]
        problem_file = inputs["problem_pddl"]
        # Stub: Sostituire con subprocess.run per Fast Downward
        is_valid = "(:goal" in problem_file
        return {"is_valid": is_valid, "log": "Stub: validazione passata" if is_valid else "Errore"}

# --- Tool: Reflection Agent ---
class ReflectAgent(BaseTool):
    name = "reflect"
    description = "Suggerisce miglioramenti al PDDL"

    def __init__(self):
        super().__init__()
        self.llm = ChatOllama(model="llama3.2", temperature=0.1, verbose=True)
        self.prompt = PromptTemplate(
            input_variables=["pddl_text"],
            template="You are a PDDL expert and logical reasoning agent. Analyze the following PDDL domain and problem. Identify logical inconsistencies or narrative gaps.
                        Suggest specific modifications to fix them.
                        PDDL:{pddl_text} Suggestion:"
        )
        self.chain = LLMChain(llm=self.llm, prompt=self.prompt)

    def _run(self, context):
        domain = context.get("domain_pddl", "")
        problem = context.get("problem_pddl", "")
        pddl_text = domain + "\n" + problem
        suggestion = self.chain.run(pddl_text=pddl_text)
        return {"suggestion": suggestion.strip()}


# --- Chat-based approval (simulato) ---
def ask_author_fn(context):
    print("\nSuggerimento del sistema:", context["suggestion"])
    return {"status": "approved"}  # Stub: Simula l'approvazione automatica



def validate_with_fast_downward(domain_str, problem_str):
    with tempfile.TemporaryDirectory() as tempdir:
        domain_path = os.path.join(tempdir, "domain.pddl")
        problem_path = os.path.join(tempdir, "problem.pddl")

        # Salva i file temporanei
        with open(domain_path, "w") as f:
            f.write(domain_str)
        with open(problem_path, "w") as f:
            f.write(problem_str)

        # Percorso a fast-downward.py
        fd_script = os.path.abspath("downward/fast-downward.py")
        
        # Comando di pianificazione (configurabile)
        command = [
            "python3", fd_script,
            domain_path,
            problem_path,
            "--search", "astar(blind())"
        ]

        try:
            result = subprocess.run(
                command,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                universal_newlines=True,
                timeout=10
            )

            if "Solution found!" in result.stdout:
                return True, result.stdout
            else:
                return False, result.stdout + result.stderr
        except subprocess.TimeoutExpired:
            return False, "Timeout nella pianificazione"



class ValidatePDDLTool(BaseTool):
    name = "validate_pddl"
    description = "Valida i file PDDL usando Fast Downward"

    def _run(self, inputs):
        domain = inputs["domain_pddl"]
        problem = inputs["problem_pddl"]
        is_valid, log = validate_with_fast_downward(domain, problem)
        return {"is_valid": is_valid, "log": log}
"""



# --- Costruzione del Grafo ---
builder = StateGraph(QuestMasterState)



builder.add_node("carica_lore", CaricaLore_node)
builder.add_node("genera_pddl", GeneraPDDL_node)
#builder.add_node("validate_pddl", ValidatePDDLTool())
#builder.add_node("reflect", ReflectAgent())
#builder.add_node("ask_author", ask_author_fn)


builder.add_edge(START, "carica_lore")
builder.add_edge("carica_lore", "genera_pddl")
#builder.add_edge("generate_pddl", "validate_pddl")

"""builder.add_conditional_edges("validate_pddl", 
    lambda x: "valid" if x["is_valid"] else "invalid",
    {
        "valid": END,
        "invalid": "reflect"
    }
)"""

#builder.add_edge("reflect", "ask_author")
"""builder.add_conditional_edges("ask_author", 
    lambda x: x["status"],
    {
        "approved": "generate_pddl",
        "modified": "update_lore"
    }
)"""

#builder.add_edge("update_lore", "generate_pddl")


# --- Compila il grafo ---
graph = builder.compile()
print("Costruzione del grafo avvenuta con successo")


# --- Avvia l'esecuzione (esempio) ---
if __name__ == "__main__":
    result = graph.invoke({"file_path": "lore_document.txt"})
    print("\nRisultato finale:", result)
