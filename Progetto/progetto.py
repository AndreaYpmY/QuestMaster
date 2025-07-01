#Progetto QuestMaster

import subprocess
import tempfile
import os
import requests

from typing import Annotated, List, Optional
from langchain_ollama import ChatOllama
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

from langgraph.graph import (StateGraph, START, END)
from langgraph.graph.message import add_messages
from langgraph.prebuilt import ToolNode, tools_condition
from langgraph.types import Command, interrupt
from typing_extensions import TypedDict
from langchain.agents import AgentExecutor


examples_problem = [
    {
        "input": "An example of problem.pddl file.",
        "output": f"""(define (problem blocksworld-example)
    (:domain blocksworld)

    (:objects
        red yellow blue orange - block
    )

    (:init
        (ontable yellow)
        (ontable orange)
        (ontable red)
        (on blue orange)
        (clear blue)
        (clear red)
        (clear yellow)
        (handempty)
    )

    (:goal
        (and
            (on orange blue)
            (ontable blue)
            (ontable yellow)
            (ontable red)
            (clear orange)
            (clear yellow)
            (clear red))
    )
)"""
    }]

examples_domain = [
    {
        "input": "An example of domain.pddl file.",
        "output": f"""(define (domain blocksworld) 
    (:requirements :strips :typing)

    (:types
        block
    )

    (:predicates
        (on ?x - block ?y - block)
        (ontable ?x - block)
        (clear ?x - block)
        (holding ?x - block)
        (handempty)
    )

    (:action pick-up
        :parameters (?x - block)
        :precondition (and (clear ?x) (ontable ?x) (handempty))
        :effect (and
            (not (ontable ?x))
            (not (clear ?x))
            (not (handempty))
            (holding ?x))
    )

    (:action put-down
        :parameters (?x - block)
        :precondition (holding ?x)
        :effect (and
            (ontable ?x)
            (clear ?x)
            (handempty)
            (not (holding ?x)))
    )

    (:action unstack
        :parameters (?x - block ?y - block)
        :precondition (and (on ?x ?y) (clear ?x) (handempty))
        :effect (and
            (holding ?x)
            (clear ?y)
            (not (on ?x ?y))
            (not (clear ?x))
            (not (handempty)))
    )

    (:action stack
        :parameters (?x - block ?y - block)
        :precondition (and (holding ?x) (clear ?y))
        :effect (and
            (on ?x ?y)
            (clear ?x)
            (handempty)
            (not (holding ?x))
            (not (clear ?y)))
    )
)"""}]

example_messages_problem = [
    [
        ("user", ex["input"]),
        ("assistant", ex["output"])
    ]
    for ex in examples_problem
]


example_messages_domain = [
    [
        ("user", ex["input"]),
        ("assistant", ex["output"])
    ]
    for ex in examples_domain
]



class QuestMasterState(TypedDict):
    """Schema for data flowing through the graph."""

    file_path: str
    lore: str
    story: str
    domain_pddl: str
    problem_pddl: str


def CaricaLore_node(state: QuestMasterState):
    with open(state["file_path"], 'r') as f:
            print("Lore document aperto con successo \n")
            content = f.read()
    return {"lore": content}


def GeneraStoria_node(state: QuestMasterState):
    llm = ChatOllama(model="mistral", temperature=0.7)
    prompt = ChatPromptTemplate.from_messages([("system", f"""You are a narrative engine that creates interactive stories in the style of a "choose your own adventure" book.
        Given a LORE document, generate the full interactive story in one pass.
        Each section must:
                        - Present a brief scene
                        - End with a set of choices between the min and max branching factor included in the lore document
                        - Clearly indicate which section each choice leads to (e.g., "Go to Section 2")
                        - The story should be complete with all branches written
        Structure: 
                Section 1:
                Text...
                Choices:
                    - Do X → Go to Section 2
                    - Do Y → Go to Section 3
                Section 2:
                Text...
                Choices:
                - ...
        For final sections do no add the choices.
        DO NOT STOP at the first section or ask for input, but continue until all section are fully written and the story include all possible paths. Be sure do not go over the max depth constraints in the lore document."""),
    ("user", "Given the following Lore Document: {lore_text} generate a fully narrative and interactive story.")])
    
    print("LLM invocato per la creazione della storia \n")
    formatted_prompt = prompt.invoke({"lore_text": state["lore"]})
    response_llm = llm.invoke(formatted_prompt)
    response = response_llm.content

    print(response)
    return{"story": response}


#Genera un file PDDL dal documento di lore
def GeneraPDDL_node(state: QuestMasterState):
    llm = ChatOllama(model="mistral", temperature=0.1)
    prompt = ChatPromptTemplate.from_messages([("system", f"""You are a skilled PDDL problem and domain generator.
                Generate a complete PDDL problem and domain text representing the given story.
                Each line of PDDL code should be followed by a comment explaining what the line does. Example comment style: ; This line declares the predicate 'at'---.
                Do no insert other text at the begin or end of the response.
                Return the problem pddl first, then the domain pddl.
                Here some examples of domain.pddl file and problem.pddl file:""" ), 
                MessagesPlaceholder(variable_name="examples"),
                ("user", "Given the following narrative story: {story_text}. Generate the pddl problem file and the pddl domain file.")])
    
    formatted_prompt = prompt.invoke({"examples": [msg for example in example_messages for msg in example],
                                    "story_text": state["story"]})
    
    print("LLM per generare il PDDL invocato \n")
    response_llm = llm.invoke(formatted_prompt)
    response = response_llm.content

    print("Risposta: ", response)

    try:
        # Splitta domain e problem PDDL
        if "(define (domain" in response:
            problem_pddl, domain_pddl = response.split("(define (domain", 1)
            
            print("Problem: ", problem_pddl, "\n Domain: ", domain_pddl, "\n")

            problem_file = open("problem.pddl", "w")
            problem_file.write(problem_pddl)
            problem_file.close()

            domain_file = "(define (domain " + domain_file
            domain_file = open("domain.pddl", "w")
            domain_file.write(domain_pddl)
            domain_file.close()
        else:
            # fallback
            raise Exception("Splitting non avvenuto con successo. (define (problem non era presente")
        return {"domain_pddl": domain_pddl.strip(), "problem_pddl": problem_pddl.strip()}
    except Exception as e:
        return f"Errore nella generazione dei PDDL: {e}"
    


def GeneraPDDLdomain_node(state: QuestMasterState):
    llm = ChatOllama(model="mistral", temperature=0.1)
    prompt = ChatPromptTemplate.from_messages([("system", f"""You are a skilled PDDL domain generator.
                Generate a complete domain PDDL representing the given story.
                Do no insert other text at the begin or end of the response, return only the domain pddl.
                Here some examples of domain PDDL file:""" ), 
                MessagesPlaceholder(variable_name="examples"),
                ("user", "Given the following narrative story: {story_text}. Generate the PDDL domain file.")])
    
    formatted_prompt = prompt.invoke({"examples": [msg for example in example_messages_domain for msg in example],
                                    "story_text": state["story"]})
    
    print("LLM per generare il PDDL domain invocato \n")
    response_llm = llm.invoke(formatted_prompt)
    domain_pddl = response_llm.content.strip()

    print("Risposta: ", domain_pddl)

    domain_file = open("domain.pddl", "w")
    domain_file.write(domain_pddl)
    domain_file.close()

    return {"domain_pddl": domain_pddl}
    


def GeneraPDDLproblem_node(state: QuestMasterState):
    llm = ChatOllama(model="mistral", temperature=0.1)
    prompt = ChatPromptTemplate.from_messages([("system", f"""You are a skilled PDDL problem generator.
                Generate a complete problem PDD representing the given story and that follow the following PDDL domain file: {{{{domain_pddl}}}}.
                Do no insert other text at the begin or end of the response, return only the problem pddl.
                Here some examples of problem.pddl file:""" ), 
                MessagesPlaceholder(variable_name="examples"),
                ("user", "Given the following narrative story: {story_text}. Generate the PDDL problem file.")])
    
    formatted_prompt = prompt.invoke({"domain_pddl": state["domain_pddl"],
                                    "examples": [msg for example in example_messages_problem for msg in example],
                                    "story_text": state["story"]})
    
    print("LLM per generare il PDDL problem invocato \n")
    response_llm = llm.invoke(formatted_prompt)
    problem_pddl = response_llm.content.strip()

    print("Risposta: ", problem_pddl)

    problem_file = open("problem.pddl", "w")
    problem_file.write(problem_pddl)
    problem_file.close()

    return {"problem_pddl": problem_pddl}



"""
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
"""

def Validate_node(state: QuestMasterState):
    url = 'http://solver.planning.domains/solve'

    with open("domain.pddl", "r") as domain_file, open("problem.pddl", "r") as problem_file:
        payload = {
            "domain": domain_file.read(),
            "problem": problem_file.read()
        }

    headers = {"Content-Type": "application/json"}

    try:
        response = requests.post(url, json=payload, headers=headers)

        # Debug in caso di fallimento
        print("HTTP Status Code:", response.status_code)
        print("Response content:", response.text[:500])  # stampiamo solo i primi 500 caratteri

        response.raise_for_status()  # Lancia errore per HTTP 4xx o 5xx
        result = response.json()  # Questo ora è sicuro

        if result.get("status") == "ok":
            print("Piano:", result["result"]["plan"])
        else:
            print("Errore nel planner:", result.get("result"))
        return result

    except requests.exceptions.RequestException as e:
        print(f"Errore durante la richiesta al planner: {e}")
        return {"status": "error", "message": str(e)}

    except ValueError as e:
        print(f"Errore nel parsing JSON: {e}")
        return {"status": "error", "message": f"Risposta non in formato JSON: {response.text}"}


"""
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
builder.add_node("genera_storia", GeneraStoria_node)

#builder.add_node("genera_pddl", GeneraPDDL_node)

builder.add_node("genera_problem_pddl", GeneraPDDLproblem_node)
builder.add_node("genera_domain_pddl", GeneraPDDLdomain_node)

builder.add_node("validate_pddl", Validate_node)

#builder.add_node("reflect", ReflectAgent())
#builder.add_node("ask_author", ask_author_fn)


builder.add_edge(START, "carica_lore")
builder.add_edge("carica_lore", "genera_storia")

#builder.add_edge("genera_storia", "genera_pddl")
builder.add_edge("genera_storia", "genera_domain_pddl")
builder.add_edge("genera_domain_pddl", "genera_problem_pddl")


#builder.add_edge("genera_pddl", "validate_pddl")


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


# --- Avvia l'esecuzione ---
if __name__ == "__main__":
    result = graph.invoke({"file_path": "lore_document.txt"})

