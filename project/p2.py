import subprocess
import tempfile
import os
import requests

from dotenv import load_dotenv
load_dotenv()

from langchain_openai import ChatOpenAI

from typing import Annotated, List, Optional
from langchain_ollama import ChatOllama
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

from langgraph.graph import (StateGraph, START, END)
from typing_extensions import TypedDict
from pydantic import BaseModel

# ----- VARIABILI -----
MODEL="llama3.2" #gpt-4o-mini o llama3.2
TEMPERATURE_STORY=0.7
TEMPERATURE_PDDL=0.05
TEMPERATURE_PDDL_DOMAIN=0.05
TEMPERATURE_PDDL_PROBLEM=0.05
TEMPERATURE_PDDL_REFLECTION=0.3
TEMPERATURE_HTML=0.1

TOP_P = 1.0

FASTDOWNWARD_PATH = "../downward"  
LORE_DOCUMENT_PATH = "lore_document.txt"  
DOMAIN_PDDL_PATH = "domain.pddl" 
PROBLEM_PDDL_PATH = "problem.pddl" 
STORY_PATH = "storia.txt"
PLAN_PATH = "sas_plan"

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
# ---------------------


# ESEMPI DI PDDL
esempi = [
    {"description": "Linehaul refers to the transportation of goods or freight between two major hubs or terminals, typically over long distances. It is a crucial part of the logistics and supply chain process, particularly in trucking, air cargo, rail, and maritime shipping.",
     "PDDL": {"domain": f"""(define (domain linehaul_without_costs)
    (:requirements :strips :typing)

    (:types
        location truck quantity - object
        refrigerated_truck - truck
    )

    (:predicates
        (at ?t - truck ?l - location)
        (free_capacity ?t - truck ?q - quantity)
        (demand_chilled_goods ?l - location ?q - quantity)
        (demand_ambient_goods ?l - location ?q - quantity)
        (plus1 ?q1 ?q2 - quantity)
    )

    ;; The effect of the delivery action is to decrease demand at
    ;; ?l and free capacity of ?t by one.
    (:action deliver_ambient
        :parameters (?t - truck ?l - location ?d ?d_less_one ?c ?c_less_one - quantity)
        :precondition (and (at ?t ?l)
            (demand_ambient_goods ?l ?d)
            (free_capacity ?t ?c)
            (plus1 ?d_less_one ?d) ; only true if x=?d,?c, x > n0
            (plus1 ?c_less_one ?c)) ; and x = x_less_one + 1
        :effect (and (not (demand_ambient_goods ?l ?d))
            (demand_ambient_goods ?l ?d_less_one)
            (not (free_capacity ?t ?c))
            (free_capacity ?t ?c_less_one))
    )

    (:action deliver_chilled
        ;; Note type restriction on ?t: it must be a refrigerated truck.
        :parameters (?t - refrigerated_truck ?l - location ?d ?d_less_one ?c ?c_less_one - quantity)
        :precondition (and (at ?t ?l)
            (demand_chilled_goods ?l ?d)
            (free_capacity ?t ?c)
            (plus1 ?d_less_one ?d) ; only true if x=?d,?c, x > n0
            (plus1 ?c_less_one ?c)) ; and x = x_less_one + 1
        :effect (and (not (demand_chilled_goods ?l ?d))
            (demand_chilled_goods ?l ?d_less_one)
            (not (free_capacity ?t ?c))
            (free_capacity ?t ?c_less_one))
    )

    (:action drive
        :parameters (?t - truck ?from ?to - location)
        :precondition (at ?t ?from)
        :effect (and (not (at ?t ?from))
            (at ?t ?to))
    )
)""", "problem": f"""(define (problem linehaul-example)
    (:domain linehaul_without_costs)

    (:objects
        ADoubleRef - refrigerated_truck
        BDouble - truck
        depot GV E BW - location
        n0 n1 n2 n3 n4 n5 n6 n7 n8 n9 n10 n11 n12 n13 n14 n15 n16 n17 n18 n19 n20 n21 n22 n23 n24 n25 n26 n27 n28 n29 n30 n31 n32 n33 n34 n35 n36 n37 n38 n39 n40 - quantity
    )

    (:init
        (at ADoubleRef depot)
        (at BDouble depot)
        (free_capacity ADoubleRef n40)
        (free_capacity BDouble n34)

        (demand_chilled_goods GV n18)
        (demand_ambient_goods GV n12)
        (demand_chilled_goods E n7)
        (demand_ambient_goods E n2)
        (demand_chilled_goods BW n3)
        (demand_ambient_goods BW n0)

        ;; Successor relations for all quantities
        (plus1 n0 n1)
        (plus1 n1 n2)
        (plus1 n2 n3)
        (plus1 n3 n4)
        (plus1 n4 n5)
        (plus1 n5 n6)
        (plus1 n6 n7)
        (plus1 n7 n8)
        (plus1 n8 n9)
        (plus1 n9 n10)
        (plus1 n10 n11)
        (plus1 n11 n12)
        (plus1 n12 n13)
        (plus1 n13 n14)
        (plus1 n14 n15)
        (plus1 n15 n16)
        (plus1 n16 n17)
        (plus1 n17 n18)
        (plus1 n18 n19)
        (plus1 n19 n20)
        (plus1 n20 n21)
        (plus1 n21 n22)
        (plus1 n22 n23)
        (plus1 n23 n24)
        (plus1 n24 n25)
        (plus1 n25 n26)
        (plus1 n26 n27)
        (plus1 n27 n28)
        (plus1 n28 n29)
        (plus1 n29 n30)
        (plus1 n30 n31)
        (plus1 n31 n32)
        (plus1 n32 n33)
        (plus1 n33 n34)
        (plus1 n34 n35)
        (plus1 n35 n36)
        (plus1 n36 n37)
        (plus1 n37 n38)
        (plus1 n38 n39)
        (plus1 n39 n40)
    )

    (:goal
        (and
            (demand_chilled_goods GV n0)
            (demand_ambient_goods GV n0)
            (demand_chilled_goods E n0)
            (demand_ambient_goods E n0)
            (demand_chilled_goods BW n0)
            (demand_ambient_goods BW n0)
            (at ADoubleRef depot)
            (at BDouble depot)
        )
    )
)"""},
    },
    {"description": "An example of blocksworld game.",
     "PDDL": {"domain": f"""(define (domain blocksworld)
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
)""", "problem": f"""(define (problem blocksworld-example)
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
)"""},
    }
]


# Conversione nel formato richiesto per langchain
messaggi_esempi_problem = [
    [
        ("user", ex["description"]),
        ("assistant", str(ex["PDDL"]))
    ]
    for ex in esempi
]

messaggi_esempi_domain = [
    [
        ("user", ex["description"]),
        ("assistant", str(ex["PDDL"]))
    ]
    for ex in esempi
]



# Definizione dello stato del QuestMaster
class QuestMasterState(TypedDict):
    file_path: str
    lore: str
    story: str
    is_valid_story: bool
    domain_pddl: str
    problem_pddl: str
    is_valid: bool
    log: str
    suggestion: dict
    acepted_suggestion_domain: list
    acepted_suggestion_problem: list



def get_model(temp: float, top_p: float | None = None):
    print(f"> Utilizzo il modello {MODEL} con temperatura {temp} e top_p {top_p}\n")

    if MODEL == "gpt-4.1-mini":
        kwargs = {"model": MODEL, "temperature": temp, "openai_api_key": OPENAI_API_KEY}
        if top_p is not None:
            kwargs["top_p"] = top_p
        return ChatOpenAI(**kwargs)
    else:
        return ChatOllama(model=MODEL, temperature=temp)



# 1. Carica il documento di lore
def CaricaLore_node(state: QuestMasterState):
    with open(state["file_path"], 'r') as f:
            print("1# Lore document aperto con successo \n")
            content = f.read()
    return {"lore": content}

# 2. Genera la storia interattiva
def GeneraStoria_node(state: QuestMasterState):
    llm = get_model(TEMPERATURE_STORY)

    prompt = ChatPromptTemplate.from_messages([("system", 
    f"""You are a narrative engine that creates structured interactive stories for PDDL planning conversion.

        CRITICAL REQUIREMENTS:
        - Extract and respect ALL constraints from the Lore Document
        - Generate a story structure that maps to planning states and actions
        - Each story section must represent a distinct WORLD STATE
        - Each choice must represent a specific ACTION that changes the world state
        - Respect branching factor: each section must have between MIN and MAX choices
        - Respect depth constraints: story must have between MIN and MAX steps to reach goal
        - May be more than one distinct goal states 

        STRUCTURE REQUIREMENTS:
        1. Start with the exact INITIAL STATE from the lore
        2. Each section describes a game state with:
            - Clear narrative description with dialogues scenes for each section that describe the story state 200-400 word of description, remaining compliant with the lore and the story
            - Current world conditions
            - Available objects/characters
            - Player location and status
        3. Each choice must be an ACTION that:
            - Has clear preconditions (what must be true to take this action)
            - Has clear effects (what changes in the world state)
            - Moves toward the GOAL STATE
            - Avoid simplistic choices (e.g., “win or lose”); instead, actions should reflect meaningful narrative decision that permit to moves toward the states

        OUTPUT FORMAT:
        Section 1: [INITIAL STATE - describe exact starting conditions]
        Narrative: [Narrative description with dialogues scenes for each section that describe the story state]
        Current State: [List current world facts]
        Available Actions:
        - [Action 1]: [Clear description] → Go to Section [X]
        - [Action 2]: [Clear description] → Go to Section [Y]
        [Continue for MIN-MAX choices as specified in lore]

        Section 2: [State after Action 1]
        Current State: [Updated world facts]
        Available Actions:
        - [Action A]: [Description] → Go to Section [Z]
        [Continue...]

        VALIDATION CHECKLIST:
        ✓ Story starts with exact initial state from lore
        ✓ Goal state is reachable within depth constraints
        ✓ Each section has branching factor within min/max range
        ✓ Actions have clear preconditions and effects
        ✓ All obstacles from lore are incorporated
        ✓ Story is complete with all paths written
        If is impossible to create the story with the given lore document and respect the constraints, returns ONLY the word "IMPOSSIBLE".

        Generate the COMPLETE story structure now and do not insert the validation checklist or summary at the end."""),
    ("user", "Lore Document: {lore_text}\n Generate a complete structured interactive story respecting ALL constraints.")])
    
    print("2# LLM invocato per la creazione della storia \n")
    formatted_prompt = prompt.invoke({"lore_text": state["lore"]})
    response_llm = llm.invoke(formatted_prompt)
    response = response_llm.content

    if response == "IMPOSSIBLE" or "IMPOSSIBLE" in response:
        return {"is_valid_story": False}
    else:
        return{"story": response, "is_valid_story": True}


def modifica_lore_node(state: QuestMasterState):
    llm= get_model(TEMPERATURE_PDDL_REFLECTION)

    prompt = ChatPromptTemplate.from_messages([("system", f"""You are an expert narrative engine that creates structured interactive storie and logical reasoning agent.
            Analyze the lore document which you can found at the end, and reflect on these file to detect problems.
            Suggest improvements that can help to reach the following goals:
                ✓ Story starts with exact initial state from lore
                ✓ Goal state is reachable within depth constraints
                ✓ Each section has branching factor within min/max range
                ✓ Actions have clear preconditions and effects
                ✓ All obstacles from lore are incorporated
                ✓ Story is complete with all paths written
                                                
            Provide a structured report with a bullet list of problems followed by the possible fixes and separate each output with "---"
            Return ONLY the bullet list of problems followed by the possible fixes and separate each output with "---", no other text.
            Return at max the 3 most important problems.
                                                
            Example of expected output:
                    - PROBLEM: "Impossible to respect the depth constraints"; SUGGESTION: "Change the min depth constraint to x and the max depth constraint to y"; ---
                    - PROBLEM: "Impossible to respect the branching factor"; SUGGESTION: "Change the min branching factor to x and the max branching factor to y"; ---
                    - PROBLEM: "Goal state is not reachable within depth constraints"; SUGGESTION: "Add 1 to the max depth constraint"; ---"""),
            
            
            ("user", "Please analyze the following lore document and suggest changes to fix the problems and permit to create a narrative story. \n Lore document: {lore}")])
    
    formatted_prompt = prompt.invoke({"lore": state["lore"]})
    
    print("# LLM per riflettere sul lore e correggerlo \n")
    response_llm = llm.invoke(formatted_prompt)
    response = response_llm.content.strip()

    try:
        suggestion = response.split("---")
        del suggestion[-1]
    except Exception as e:
        return f"4# Errore nella ricezione dei suggerimenti. Separatore non corretti: {e}"
    
    accepted_suggestion = []
    for s in suggestion:
        print("> " + s + "\n")
        u_input = input("Vuoi accettare questa modifica? (y/n): ")
        if u_input == "y":
            accepted_suggestion.append(s)
    
    prompt2 = ChatPromptTemplate.from_messages([("system", f"""You are an expert in create lore document to creare narrative stories.
            Analyze the lore document which you can found at the end and modify it by the suggestions.
            Making minimal necessary changes for correctness and solvability, USING ONLY the suggestions given
            Focus on preserving the original structure and content as much as possible.
            Return ONLY the lore document text, NO OTHER TEXT."""), 
            
            ("user", "Please modify the following lore document to permit to create a narrative story, using the following succestions: {s}. \n Lore document: {lore}")])
    
    formatted_prompt2 = prompt2.invoke({"lore": state["lore"], "s": accepted_suggestion})
    print("# LLM per correggere lore \n")
    response_llm = llm.invoke(formatted_prompt2)
    response = response_llm.content.strip()

    lore_file = open(LORE_DOCUMENT_PATH, "w")
    lore_file.write(response)
    lore_file.close()

    return {"lore": response}



# 3A. Genera il PDDL domain
def GeneraPDDLdomain_node(state: QuestMasterState):
    
    llm = get_model(TEMPERATURE_PDDL_DOMAIN)
    
    prompt = ChatPromptTemplate.from_messages([("system", f"""You are an expert PDDL domain generator for the QuestMaster interactive story system.
                Generate a complete and valid PDDL domain file from the given interactive story.
                
                CRITICAL DOMAIN PDDL REQUIREMENTS:
                    1. Each line must have a comment explaining what it does
                    2. Define predicates that capture ALL story states and conditions
                    3. Create actions for EVERY choice mentioned in the story
                    4. Ensure actions have proper preconditions and effects
                    5. Include object types for characters, items, locations
                    6. Make sure the domain supports the narrative flow
                                                     
                Standard domain PDDL structure to follow:
                (define (domain quest-domain)
                    (:requirements :strips :typing :negative-preconditions)
                    (:types ; Define object types with comments
                        location character item - object
                    )
                    (:predicates    ; Define predicates with clear comments
                        (at ?obj - object ?loc - location) ; Object is at location
                        (has ?char - character ?item - item) ; Character has item
                        ; ... more predicates
                    )
                    (:action action-name
                        :parameters (?param - type)
                        :precondition (and 
                            ; Conditions that must be true
                    )
                    :effect (and
                        ;Changes to the world state
                        )
                    )
                )

                DO NOT invent predicates, objects or goals that are not justified by the story.
                DO A DOUBLE CHECK of the output for syntax errors and for be sure the PDDLs MUST be solvable by a classical planner as Fast Downward.
                Return ONLY the PDDL domain code, which begins with "(define (domain...", no other text at begin or end of the PDDL file."""), 
                MessagesPlaceholder(variable_name="examples"),
                ("user", "Given the interactive story, generate the corresponding PDDL domain file with detailed comments. Check the validation of the output \n Story {story_text}. ")])
        
    formatted_prompt = prompt.invoke({"story_text": state["story"], "examples": [msg for esempi in messaggi_esempi_domain for msg in esempi]})
    

    
    print("3A# LLM per generare il PDDL domain invocato \n")
    response_llm = llm.invoke(formatted_prompt)
    domain_pddl = response_llm.content.strip()

    domain_file = open(DOMAIN_PDDL_PATH, "w")
    domain_file.write(domain_pddl)
    domain_file.close()

    return {"domain_pddl": domain_pddl}
    

# 3B. Genera il PDDL problem
def GeneraPDDLproblem_node(state: QuestMasterState):
    
    llm= get_model(TEMPERATURE_PDDL_PROBLEM)

    
    prompt = ChatPromptTemplate.from_messages([("system", f"""You are an expert PDDL problem generator for the QuestMaster interactive story system..
            Generate a complete and valid valid PDDL problem file from the given interactive story and the corrisponding PDDL domain file.
                                                
            CRITICAL PROBLEM PDDL REQUIREMENTS:
                1. Each line must have a comment explaining what it does
                2. Define ALL objects mentioned in the story (characters, items, locations)
                3. Set up initial state that matches the story's beginning
                4. Define goal state that matches the story's objective
                5. Ensure consistency with the provided domain file
                6. Use proper PDDL syntax and typing
                                                    
            Standard problem PDDL problem structure:
                (define (problem quest-problem)
                    (:domain quest-domain)
                    (:objects   ; Define all story objects with their types
                        player - character ; The main character
                        location1 location2 - location ; Story locations
                        key sword - item ; Story items
                    )
                    (:init  ; Initial world state - where story begins
                        (at player location1) ; Player starts here
                        (at key location2) ; Key is here
                        ; ... more initial conditions
                    )
                    (:goal  ; Goal condition - what needs to be achieved
                        (and (goal-achieved) ; Story objective completed
                            ; ... other goal conditions
                        )
                    )
                )
            
            DO NOT invent predicates, objects or goals that are not justified by the story.
            DO A DOUBLE CHECK of the output for syntax errors and for be sure the PDDL problem file MUST be solvable by a classical planner as Fast Downward given the domain.
            Return ONLY the PDDL problem code, which begins with "(define (problem...", no other text at begin or end of the PDDL file."""), 
            MessagesPlaceholder(variable_name="examples"),
            ("user", "Given the interactive story and the corrisponding PDDL domain file, generate the corresponding PDDL problem file, with detailed comments, in order to be solvable by a classical planner with the domain PDLL. \n Domain PDDL: {domain_pddl}. \n Story: {story_text}.")])
    
    formatted_prompt = prompt.invoke({"domain_pddl": state["domain_pddl"], "story_text": state["story"], "examples": [msg for esempi in messaggi_esempi_problem for msg in esempi]})
    

    print("3B# LLM per generare il PDDL problem invocato \n")
    response_llm = llm.invoke(formatted_prompt)
    problem_pddl = response_llm.content.strip()

    problem_file = open(PROBLEM_PDDL_PATH, "w")
    problem_file.write(problem_pddl)
    problem_file.close()
    
    return {"problem_pddl": problem_pddl}



def validate_with_downward(
        domain_file:str = DOMAIN_PDDL_PATH,
        problem_file:str = PROBLEM_PDDL_PATH,
        downward_path:str = FASTDOWNWARD_PATH):

    print("4# Validazione PDDL con Fast Downward... \n")
    command = [
        "python3", os.path.join(downward_path, "fast-downward.py"),
        domain_file,
        problem_file,
        "--search", "astar(blind())"
    ]
    try:
        result = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            timeout=100
        )
        log_output = result.stdout + "\n" + result.stderr

        if "Solution found!" in result.stdout or "Plan found" in result.stdout:
            print("✅ Il problema è risolvibile.")
            return True, log_output
        elif "unsolvable" in result.stdout.lower():
            print("❌ Il problema non è risolvibile.")
            return False, log_output
        else:
            print("⚠️ Nessuna soluzione trovata, controlla i file PDDL.")
            return False, log_output
    except FileNotFoundError:
        error_msg="❌ Fast Downward non trovato. Assicurati che il percorso sia corretto."
        print(error_msg)
        return False, error_msg
    except Exception as e:
        error_msg=f"❌ L'errore durante la validazione: {e}"
        print(error_msg)
        return False, error_msg
    


def extract_planner_error_block(log_text):
    lines = log_text.strip().splitlines()
    lenght = len(lines)
    error_block = lines[lenght-6:lenght-3]
    return error_block

    
def ValidatePDDL_node(state: QuestMasterState):
    is_valid, log = validate_with_downward()
    print(f"4# Validazione PDDL completata: {is_valid}, log: {log} \n")
    return {"is_valid": is_valid, "log": log}



class IssueDetail(BaseModel):
    issue: str
    fix: str

class PDDLIssue(BaseModel):
    domain_issue: List[IssueDetail]
    problem_issue: List[IssueDetail]

class PDDLfix(BaseModel):
    pddl_issue: PDDLIssue



# ---Reflection pattern ---
def reflection_node(state: QuestMasterState):
    #errors = extract_planner_error_block(state["log"])
    error = state["log"]

    llm= get_model(TEMPERATURE_PDDL_REFLECTION, TOP_P).with_structured_output(PDDLfix)

    prompt = ChatPromptTemplate.from_messages([("system", f"""You are a PDDL expert and logical reasoning agent.
            Analyze the PDDLs files which you can found at the end, and reflect on these files to detect issues, logical inconsistencies, narrative gaps and suggest improvements, based on the error message given from the planner and remaining complient with the given story.
                                                
            Follow these steps carefully: 
                1. Make syntax validation:
                    Check whether the two files are SYNTACTICALLY CORRECT:
                        a. The domain.pddl file must correctly define:
                            - (define (domain ...))
                            - :predicates, :action, :parameters, :precondition, :effect, etc.
                        b. The problem.pddl file must include:
                            - (define (problem ...))
                            - (domain ...), :objects, :init, :goal, etc.
                        c. Missing parentheses
                        d. Undeclared or mismatched names
                        e. Invalid PDDL constructs

                2. Make semantic validation:
                    If syntax is valid, analyze whether the GOAL IS LOGICALLY ACHIEVABLE:
                        a. Is the goal state reachable based on the initial state and available actions?
                        b. Are the objects, predicates, and actions in the domain properly used to progress toward the goal?
                        c. Are there missing actions or predicates that prevent reaching the goal?
                                                
                3. If the planner error says "no plans found", first list all possible actions from the initial state. Then simulate whether these actions can progress the state toward the goal. If not, explain what's missing.

                4. Generate a structured output, where you separate PDDL domain-related issues from the PDDL problem-related issues
                Provide a structured JSON like response of problems followed by the possible fixes
                        - [ ] Briefly describe each syntax error (e.g., "Missing closing parenthesis in `:action move`") and suggest a fix for each issue.
                        - [ ] If the planner cannot reach the goal, explain why (e.g., There is no action that makes door-open true) and suggest changes to the domain or problem to make the goal achievable.
                                                
            
            Return at max the 10 most important problems and fixes to resolve the error given from the planner."""),
            
            
            ("user", "Please analyze the following PDDL domain and problem files and suggest changes to fix the given error and other syntax and logical errors, so that the PDDL is solvable by a classical planner. \n ERROR: *{error}* \n Domain PDDL: {domain_pddl} \n Problem PDDL: {problem_pddl} \n Story: {story}")])
    
    formatted_prompt = prompt.invoke({"domain_pddl": state["domain_pddl"], "problem_pddl": state["problem_pddl"], "error": error, "story": state["story"]})
    
    print("4# LLM per riflettere sui PDDL e correggerli \n")
    response_llm = llm.invoke(formatted_prompt)
    response = response_llm

    suggestion = response

    return {"suggestion": suggestion}



def human_in_the_loop_node(state: QuestMasterState):
    print("5# Proposte di modifica: \n")

    suggestion = state["suggestion"]
    accepted_suggestion_domain = []
    accepted_suggestion_problem = []

    print("DOMAIN ISSUES:")
    for i, item in enumerate(suggestion.pddl_issue.domain_issue, 1):
        print(f"{i}. Issue: {item.issue} \n Fix:   {item.fix}")
        u_input = input("> Vuoi accettare questa modifica? (y/n): ")
        if u_input == "y":
            accepted_suggestion_domain.append(item)

    print("\nPROBLEM ISSUES:")
    for i, item in enumerate(suggestion.pddl_issue.problem_issue, 1):
        print(f"{i}. Issue: {item.issue} \n Fix:   {item.fix}")
        u_input = input("> Vuoi accettare questa modifica? (y/n): ")
        if u_input == "y":
            accepted_suggestion_problem.append(item)
          
    return {"acepted_suggestion_domain": accepted_suggestion_domain, "acepted_suggestion_problem": accepted_suggestion_problem}



def fix_pddl_node(state: QuestMasterState):
    print("6# Correzione PDDL tramite i suggerimenti \n")

    llm= get_model(TEMPERATURE_PDDL_REFLECTION, TOP_P)

    prompt_domain = ChatPromptTemplate.from_messages([("system", f"""You are a PDDL expert generator agent and repair assistant.
                Generate a new PDDL domain file accordingly to fix the issues, focus on preserving the original structure and content as much as possible, making minimal necessary changes for correctness and solvability.
                Use the domain-related suggestions to correct all detected problems, including syntax errors and logical inconsistencies, so that: The PDDL syntax is fully valid.                        
                
                DO NOT invent predicates, objects or goals that are not justified by the story.
                DO A DOUBLE CHECK of the output for syntax errors and for be sure the PDDLs MUST be solvable by a classical planner as Fast Downward.
                Return ONLY the PDDL domain code, which begins with "(define (domain...", no other text at begin or end of the PDDL file."""),
            ("user", "Apply the following FIXES one by one to the given PDDL domain, in ordert to correct the issue and make the PDDL solvable by a classical planner. \n FIXES: {suggestion}. \n Domain PDDL: {domain_pddl}. \n")])
    
    prompt_problem = ChatPromptTemplate.from_messages([("system", f"""You are a PDDL expert generator agent and repair assistant.
                Generate a new PDDL problem file accordingly to fix the issues, focus on preserving the original structure and content as much as possible, making minimal necessary changes for correctness and solvability.
                Use the problem-related suggestions to correct all detected problems, including syntax errors and logical inconsistencies, so that:
                    - The PDDL syntax is fully valid.
                    - The problem is solvable: the goal is reachable from the initial state using the defined actions.                        
                                            
                DO NOT invent predicates, objects or goals that are not justified by the story.
                DO A DOUBLE CHECK of the output for syntax errors and for be sure the PDDLs MUST be solvable by a classical planner as Fast Downward.
                Return ONLY the PDDL problem code, which begins with "(define (problem...", no other text at begin or end of the PDDL file."""),
            ("user", "Apply the following FIXES one by one to the given PDDL problem, in ordert to correct the issue and make the PDDLs solvable by a classical planner. Generate the new corresponding PDDL problem file accordingly to the PDDL domain file. \n FIXES: {suggestion}. \n Domain PDDL: {domain_pddl}. \n Problem PDDL: {problem_pddl}.")])
    
    formatted_prompt_domain = prompt_domain.invoke({"domain_pddl": state["domain_pddl"], "suggestion": state["acepted_suggestion_domain"]})
    formatted_prompt_problem = prompt_problem.invoke({"domain_pddl": state["domain_pddl"], "problem_pddl": state["problem_pddl"], "suggestion": state["acepted_suggestion_problem"]})

    print("6# Generazione nuovi PDDL \n")
    response_domain = llm.invoke(formatted_prompt_domain)
    response_problem = llm.invoke(formatted_prompt_problem)
    
    domain_pddl = response_domain.content.strip()
    problem_pddl = response_problem.content.strip()


    problem_file = open("problem.pddl", "w")
    problem_file.write(problem_pddl)
    problem_file.close()


    domain_file = open("domain.pddl", "w")
    domain_file.write(domain_pddl)
    domain_file.close()

    return {"domain_pddl": domain_pddl, "problem_pddl": problem_pddl}



def generate_HTML_node(state: QuestMasterState):
    lore = state["lore"]
    problem_pddl = state["problem_pddl"]
    domain_pddl = state["domain_pddl"]
    story = state["story"]
    plan = ""

    with open(PLAN_PATH, 'r') as f:
        plan = f.read()

    print("7# Generazione HTML \n")

    llm= get_model(TEMPERATURE_HTML)

    prompt = ChatPromptTemplate.from_messages([("system", f"""You are an intelligent agent that acts as both a narrative game engine and an expert developer in HTML, CSS, and JavaScript.  
            Your goal is to generate a fully self-contained, dynamic, and interactive sci-fi HTML adventure game, based on narrative and PDDL planning input.  
            Your output must be a single, valid, standalone HTML document, playable in any modern web browser, using only HTML, CSS, and vanilla JavaScript (no libraries or dependencies).  

            ### Input context
            You will be given:
                - A Lore document describing the sci-fi world and context
                - A Narrative story describing the interactive quest
                - A PDDL Domain file
                - A PDDL Problem file
                - A sequence of plan steps generated by a classical planner

            Use this input to generate the full game logic and narrative flow.

            ### Structure of the output
            Your output must include:
                1. A full HTML page that contains everything needed to play the game (HTML, CSS, JS in one file)
                2. A Start Page:
                    - Shows a summary of the story
                    - A "Start Game" button to begin
                3. Interactive Gameplay:
                    - Each story segment or plan step must appear sequentially
                    - Use interactive buttons to let the player proceed
                    - When multiple story paths or options exist, display one button for each choice
                    - After each choice, the next scene or plan step should reflect the selected path
                4. Game State Management:
                    - Track player progress and choices using JavaScript variables
                    - Support branching logic and dynamically update the DOM to show new scenes
                    - Avoid page reloads: use JavaScript to control screen transitions and content
                5. Final Scene:
                    - Display a custom ending based on the path followed
                    - Include a "Play Again" button that resets the game and returns to the Start Page
                6. Text translation:
                    - All narrative and visible text must be translated into Italian
                7. Design Requirements:
                    - Use a minimalist, modern, light-themed interface
                    - Use readable fonts, proper spacing, and centered layout
                    - Buttons should be clearly visible, styled appropriately, and show hover/focus effects
                    - Use basic CSS transitions (fade-in/out, smooth appearance) to enhance experience
                    - The layout must be responsive and mobile-friendly

            ### Do NOT include:
            - Any external files or libraries (like Bootstrap, jQuery, etc.)
            - Markdown formatting (e.g., no triple backticks, no language tags like `html`)
            - Comments or explanation outside the HTML document
            - Any broken or unclosed tags — HTML must be valid and complete

            ### Final instruction
            Return only the complete and valid HTML document as plain text, with:
            - All HTML elements properly nested and closed
            - All visible text wrapped in HTML tags
            - All interactive logic and story implemented in vanilla JavaScript inside the HTML file
            - All narrative parts written in Italian, including UI elements
                                                
            Please generate the full interactive HTML adventure game based on these inputs."""),
            ("user", "Please generate the FULL interactive HTML game, playable entirely in the frontend, with CSS and Javascript given the following input: Here is the Lore document describing the story world and quest:{lore} \n Here is the story describing the narrative: {story} \n Here is the PDDL Domain file: {domain} \n Here is the PDDL Problem file: {problem} \n Here is the ordered list of plan steps generated by the classical planner: {plan}.")])
    
    formatted_prompt = prompt.invoke({"lore": lore, "story": story, "domain": domain_pddl, "problem": problem_pddl, "plan": plan})
    

    response_llm = llm.invoke(formatted_prompt)
    response = response_llm.content.strip()

    template = open("gioco.html", "w")
    template.write(response)
    template.close()

    os.remove(PLAN_PATH)
    print("HTML generato: FINE")
    return {"HTML": response}


# --- Costruzione del Grafo ---
builder = StateGraph(QuestMasterState)

# --- Aggiunta dei nodi al grafo ---

# 1. Carica il documento di lore
builder.add_node("carica_lore", CaricaLore_node)

# 2. Genera la storia
builder.add_node("genera_storia", GeneraStoria_node)
builder.add_node("invalid_story", modifica_lore_node)


# 3. Genera i file PDDL
builder.add_node("genera_domain_pddl", GeneraPDDLdomain_node)
builder.add_node("genera_problem_pddl", GeneraPDDLproblem_node)


# 4. Validazione del PDDL
builder.add_node("validate_pddl", ValidatePDDL_node)

# 5. Pattern reflection per aggiustare il PDDL
builder.add_node("reflect", reflection_node)
builder.add_node("human", human_in_the_loop_node)
builder.add_node("fix", fix_pddl_node)

#6. Generazione HTML
builder.add_node("genera_HTML", generate_HTML_node)


# --- Collegamento dei nodi ---
builder.add_edge(START, "carica_lore")
builder.add_edge("carica_lore", "genera_storia")


builder.add_conditional_edges("genera_storia",
    lambda x: "valid" if x["is_valid_story"] else "invalid",
    {
        "valid": "genera_domain_pddl",
        "invalid": "invalid_story"
    })

builder.add_edge("invalid_story", "genera_storia")

builder.add_edge("genera_domain_pddl", "genera_problem_pddl")
builder.add_edge("genera_problem_pddl", "validate_pddl")

builder.add_conditional_edges("validate_pddl", 
    lambda x: "valid" if x["is_valid"] else "invalid",
    {
        "valid": "genera_HTML",
        "invalid": "reflect"
    })

builder.add_edge("reflect", "human")
builder.add_edge("human", "fix")
builder.add_edge("fix", "validate_pddl")

builder.add_edge("genera_HTML", END)


# --- Compila il grafo ---
graph = builder.compile()
print("Costruzione del grafo avvenuta con successo")


def select_model():
    print("=== Seleziona il Modello ===")
    print("2 - gpt-4.1-mini")

    return "gpt-4.1-mini"

# --- Avvia l'esecuzione ---
if __name__ == "__main__":
    MODEL = select_model()
    # Eseguo il grafo
    result = graph.invoke({"file_path": LORE_DOCUMENT_PATH}, {"recursion_limit": 100})
