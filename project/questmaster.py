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
from langgraph.graph.message import add_messages
from langgraph.prebuilt import ToolNode, tools_condition
from langgraph.types import Command, interrupt
from typing_extensions import TypedDict
from langchain.agents import AgentExecutor






# ----- VARIABILI -----
MODEL="llama3.2" #gpt-4o-mini o llama3.2
TEMPERATURE_STORY=0.7
TEMPERATURE_PDDL_DOMAIN=0.1
TEMPERATURE_PDDL_PROBLEM=0

FASTDOWNWARD_PATH = "../downward"  
LORE_DOCUMENT_PATH = "lore_document.txt"  
DOMAIN_PDDL_PATH = "domain.pddl" 
PROBLEM_PDDL_PATH = "problem.pddl" 

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
# ---------------------



# ESEMPI DI PDDL

examples_domain = [
    {
        "input": "An example of a narrative quest domain.pddl file for interactive storytelling.",
        "output": f"""(define (domain quest-adventure)
    (:requirements :strips :typing :negative-preconditions) ; Standard PDDL requirements

    (:types
        character location item key door - object  ; Basic object types for quests
        player npc - character                     ; Characters: player and NPCs
        room outdoor - location                    ; Location types: indoor and outdoor
        weapon tool treasure - item               ; Item categories for adventures
    )

    (:predicates
        ; Location and movement predicates
        (at ?obj - object ?loc - location)        ; Object/character is at location
        (connected ?loc1 - location ?loc2 - location) ; Locations are connected
        (blocked ?loc1 - location ?loc2 - location)   ; Path between locations is blocked
        
        ; Character state predicates
        (has ?char - character ?item - item)      ; Character possesses an item
        (alive ?char - character)                 ; Character is alive
        (friendly ?npc - npc)                     ; NPC is friendly to player
        (hostile ?npc - npc)                      ; NPC is hostile to player
        
        ; Item and interaction predicates
        (unlocks ?key - key ?door - door)         ; Key unlocks specific door
        (locked ?door - door)                     ; Door is locked
        (open ?door - door)                       ; Door is open
        (hidden ?item - item ?loc - location)    ; Item is hidden at location
        (visible ?item - item ?loc - location)   ; Item is visible at location
        
        ; Quest state predicates
        (quest-completed)                         ; Main quest is completed
        (can-fight ?char - character)            ; Character can engage in combat
        (defeated ?char - character)             ; Character has been defeated
    )

    (:action move
        :parameters (?p - player ?from - location ?to - location)
        :precondition (and 
            (at ?p ?from)                         ; Player is at starting location
            (connected ?from ?to)                 ; Locations are connected
            (not (blocked ?from ?to))             ; Path is not blocked
        )
        :effect (and 
            (at ?p ?to)                          ; Player moves to destination
            (not (at ?p ?from))                  ; Player no longer at origin
        )
    )

    (:action take-item
        :parameters (?p - player ?item - item ?loc - location)
        :precondition (and 
            (at ?p ?loc)                         ; Player is at location
            (visible ?item ?loc)                 ; Item is visible at location
            (not (has ?p ?item))                 ; Player doesn't already have item
        )
        :effect (and 
            (has ?p ?item)                       ; Player now has the item
            (not (visible ?item ?loc))           ; Item no longer visible at location
        )
    )

    (:action unlock-door
        :parameters (?p - player ?key - key ?door - door ?loc - location)
        :precondition (and 
            (at ?p ?loc)                         ; Player is at door location
            (at ?door ?loc)                      ; Door is at same location
            (has ?p ?key)                        ; Player has the key
            (unlocks ?key ?door)                 ; Key unlocks this door
            (locked ?door)                       ; Door is currently locked
        )
        :effect (and 
            (open ?door)                         ; Door becomes open
            (not (locked ?door))                 ; Door is no longer locked
        )
    )

    (:action search-location
        :parameters (?p - player ?item - item ?loc - location)
        :precondition (and 
            (at ?p ?loc)                         ; Player is at location
            (hidden ?item ?loc)                  ; Item is hidden at location
        )
        :effect (and 
            (visible ?item ?loc)                 ; Item becomes visible
            (not (hidden ?item ?loc))            ; Item is no longer hidden
        )
    )

    (:action talk-to-npc
        :parameters (?p - player ?npc - npc ?loc - location)
        :precondition (and 
            (at ?p ?loc)                         ; Player is at location
            (at ?npc ?loc)                       ; NPC is at same location
            (alive ?npc)                         ; NPC is alive
            (friendly ?npc)                      ; NPC is friendly
        )
        :effect (and 
            ; Talking might reveal information or change NPC state
            ; Effects would be specific to story context
        )
    )

    (:action complete-quest
        :parameters (?p - player ?treasure - treasure ?loc - location)
        :precondition (and 
            (at ?p ?loc)                         ; Player is at final location
            (has ?p ?treasure)                   ; Player has the quest item
        )
        :effect (and 
            (quest-completed)                    ; Quest is marked as completed
        )
    )
)"""
    },
    {
        "input": "An example of a simple dungeon exploration domain.pddl file.",
        "output": f"""(define (domain dungeon-quest)
    (:requirements :strips :typing)               ; PDDL requirements declaration

    (:types
        location character item - object           ; Basic object hierarchy
        room corridor - location                  ; Specific location types
        hero monster - character                  ; Character types
        sword potion key - item                   ; Item types
    )

    (:predicates
        (at ?obj - object ?loc - location)        ; Object location predicate
        (connected ?loc1 - location ?loc2 - location) ; Location connectivity
        (has-item ?char - character ?item - item) ; Character inventory
        (door-open ?from - location ?to - location) ; Door state between locations
        (monster-defeated ?m - monster)           ; Monster defeat status
        (treasure-found)                          ; Victory condition
    )

    (:action move-to-room
        :parameters (?h - hero ?from - location ?to - location)
        :precondition (and 
            (at ?h ?from)                         ; Hero at starting location
            (connected ?from ?to)                 ; Rooms are connected
            (door-open ?from ?to)                 ; Door between rooms is open
        )
        :effect (and 
            (at ?h ?to)                          ; Hero moves to new room
            (not (at ?h ?from))                  ; Hero leaves old room
        )
    )

    (:action pick-up-item
        :parameters (?h - hero ?item - item ?loc - location)
        :precondition (and 
            (at ?h ?loc)                         ; Hero at item location
            (at ?item ?loc)                      ; Item at same location
        )
        :effect (and 
            (has-item ?h ?item)                  ; Hero acquires item
            (not (at ?item ?loc))                ; Item removed from location
        )
    )

    (:action fight-monster
        :parameters (?h - hero ?m - monster ?s - sword ?loc - location)
        :precondition (and 
            (at ?h ?loc)                         ; Hero at monster location
            (at ?m ?loc)                         ; Monster at same location
            (has-item ?h ?s)                     ; Hero has sword
        )
        :effect (and 
            (monster-defeated ?m)                ; Monster is defeated
            (not (at ?m ?loc))                   ; Monster removed from location
        )
    )
)"""
    }
]

examples_problem = [
    {
        "input": "An example of a narrative quest problem.pddl file for interactive storytelling.",
        "output": f"""(define (problem treasure-quest)
    (:domain quest-adventure)                    ; References the quest-adventure domain

    (:objects
        ; Characters in the story
        hero - player                            ; The main character (player)
        guard wizard - npc                       ; Non-player characters
        
        ; Locations in the adventure
        village-square castle-entrance throne-room treasure-chamber - room
        forest-path mountain-trail - outdoor     ; Outdoor locations
        
        ; Items needed for the quest
        rusty-sword magic-potion - weapon        ; Weapons available
        golden-key silver-key - key             ; Keys for doors
        ancient-scroll - tool                    ; Quest-related tool
        dragon-treasure - treasure              ; The ultimate goal
        
        ; Interactive elements
        castle-door chamber-door - door          ; Doors to unlock
    )

    (:init
        ; Initial character positions
        (at hero village-square)                ; Hero starts in village
        (at guard castle-entrance)              ; Guard blocks castle entrance
        (at wizard throne-room)                 ; Wizard in throne room
        
        ; Initial item locations
        (visible rusty-sword village-square)    ; Sword visible in village
        (hidden golden-key castle-entrance)     ; Key hidden at castle
        (visible ancient-scroll throne-room)    ; Scroll visible in throne room
        (at dragon-treasure treasure-chamber)   ; Treasure in final chamber
        
        ; Door and key relationships
        (at castle-door castle-entrance)        ; Castle door location
        (at chamber-door treasure-chamber)      ; Chamber door location
        (unlocks golden-key castle-door)        ; Golden key opens castle door
        (unlocks silver-key chamber-door)       ; Silver key opens chamber door
        (locked castle-door)                    ; Castle door starts locked
        (locked chamber-door)                   ; Chamber door starts locked
        
        ; Location connections
        (connected village-square castle-entrance) ; Village connects to castle
        (connected castle-entrance throne-room)    ; Castle entrance to throne room
        (connected throne-room treasure-chamber)   ; Throne room to treasure chamber
        
        ; Initial character states
        (alive hero)                            ; Hero is alive
        (alive guard)                           ; Guard is alive
        (alive wizard)                          ; Wizard is alive
        (friendly wizard)                       ; Wizard is helpful
        (hostile guard)                         ; Guard is initially hostile
    )

    (:goal
        (and 
            (quest-completed)                   ; Main objective: complete the quest
            (at hero treasure-chamber)          ; Hero reaches final location
            (has hero dragon-treasure)          ; Hero possesses the treasure
        )
    )
)"""
    },
    {
        "input": "An example of a simple dungeon problem.pddl file.",
        "output": f"""(define (problem dungeon-adventure)
    (:domain dungeon-quest)                     ; Uses dungeon-quest domain

    (:objects
        player - hero                           ; The player character
        goblin orc - monster                    ; Enemies to defeat
        entrance main-hall treasure-room - room ; Dungeon rooms
        corridor1 corridor2 - corridor          ; Connecting corridors
        iron-sword - sword                      ; Weapon for combat
        healing-potion - potion                 ; Healing item
        dungeon-key - key                       ; Key for locked doors
    )

    (:init
        ; Starting positions
        (at player entrance)                    ; Player starts at dungeon entrance
        (at goblin main-hall)                   ; Goblin in main hall
        (at orc treasure-room)                  ; Orc guards treasure room
        
        ; Item locations
        (at iron-sword entrance)                ; Sword available at start
        (at healing-potion main-hall)           ; Potion in main hall
        (at dungeon-key main-hall)              ; Key in main hall
        
        ; Room connections
        (connected entrance corridor1)          ; Entrance to first corridor
        (connected corridor1 main-hall)         ; Corridor to main hall
        (connected main-hall corridor2)         ; Main hall to second corridor
        (connected corridor2 treasure-room)     ; Corridor to treasure room
        
        ; Door states (all doors start open for simplicity)
        (door-open entrance corridor1)          ; First door is open
        (door-open corridor1 main-hall)         ; Second door is open
        (door-open main-hall corridor2)         ; Third door is open
        (door-open corridor2 treasure-room)     ; Final door is open
    )

    (:goal
        (and 
            (treasure-found)                    ; Main goal: find treasure
            (monster-defeated goblin)           ; Defeat goblin
            (monster-defeated orc)              ; Defeat orc
            (at player treasure-room)           ; Player reaches treasure room
        )
    )
)"""
    }
]

# Conversione nel formato richiesto per langchain
example_messages_domain = [
    [
        ("user", ex["input"]),
        ("assistant", ex["output"])
    ]
    for ex in examples_domain
]

example_messages_problem = [
    [
        ("user", ex["input"]),
        ("assistant", ex["output"])
    ]
    for ex in examples_problem
]



# Definizione dello stato del QuestMaster
class QuestMasterState(TypedDict):
    file_path: str
    lore: str
    story: str
    domain_pddl: str
    problem_pddl: str

def get_model(temp:float):
    """
    Restituisce il modello da utilizzare per la generazione della storia e del PDDL.
    """
    print(f"> Utilizzo il modello {MODEL} con temperatura {temp}\n")
    if MODEL == "gpt-4o-mini":
        return ChatOpenAI(model=MODEL, temperature=temp, openai_api_key=OPENAI_API_KEY)
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

        STRUCTURE REQUIREMENTS:
        1. Start with the exact INITIAL STATE from the lore
        2. Each section describes a game state with:
            - Current world conditions
            - Available objects/characters
            - Player location and status
        3. Each choice must be an ACTION that:
            - Has clear preconditions (what must be true to take this action)
            - Has clear effects (what changes in the world state)
            - Moves toward the GOAL STATE

        OUTPUT FORMAT:
        Section 1: [INITIAL STATE - describe exact starting conditions]
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

        Generate the COMPLETE story structure now."""),
    ("user", "Lore Document: {lore_text}\nGenerate the complete structured interactive story respecting ALL constraints.")])
    
    print("2# LLM invocato per la creazione della storia \n")
    formatted_prompt = prompt.invoke({"lore_text": state["lore"]})
    response_llm = llm.invoke(formatted_prompt)
    response = response_llm.content

    print("--- 2# ---\n "+response)
    return{"story": response}

    

# 3A. Genera il PDDL domain
def GeneraPDDLdomain_node(state: QuestMasterState):
    
    llm = get_model(TEMPERATURE_PDDL_DOMAIN)

    prompt = ChatPromptTemplate.from_messages([("system", f"""You are an expert PDDL domain generator for the QuestMaster interactive story system.
                
                Generate a complete and valid PDDL domain file from the given interactive story.
                
                CRITICAL REQUIREMENTS:
                1. Each line must have a comment explaining what it does
                2. Define predicates that capture ALL story states and conditions
                3. Create actions for EVERY choice mentioned in the story
                4. Ensure actions have proper preconditions and effects
                5. Include object types for characters, items, locations
                6. Make sure the domain supports the narrative flow
                
                Standard PDDL structure to follow:
                (define (domain quest-domain)
                    (:requirements :strips :typing :negative-preconditions)
                    (:types
                    ; Define object types with comments
                    location character item - object
                    )
                    (:predicates
                    ; Define predicates with clear comments
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
                    ; Changes to the world state
                    )
                )
            )
                
                Return ONLY the PDDL domain code, which begins with "(define (domain...", no other text.""" ), 
                MessagesPlaceholder(variable_name="examples"),
                ("user", "Interactive Story: {story_text}\n\nGenerate the corresponding PDDL domain file with detailed comments.")])
    
    formatted_prompt = prompt.invoke({"examples": [msg for example in example_messages_domain for msg in example],
                                    "story_text": state["story"]})
    
    print("3A# LLM per generare il PDDL domain invocato \n")
    response_llm = llm.invoke(formatted_prompt)
    domain_pddl = response_llm.content.strip()

    print("3# Risposta: ", domain_pddl)

    domain_file = open(DOMAIN_PDDL_PATH, "w")
    domain_file.write(domain_pddl)
    domain_file.close()

    return {"domain_pddl": domain_pddl}
    

# 3B. Genera il PDDL problem
def GeneraPDDLproblem_node(state: QuestMasterState):
    
    llm= get_model(TEMPERATURE_PDDL_PROBLEM)

    prompt = ChatPromptTemplate.from_messages([("system", f"""You are an expert PDDL problem generator for the QuestMaster system.
                
                Generate a complete PDDL problem file that corresponds to the given story and domain.
                
                CRITICAL REQUIREMENTS:
                1. Each line must have a comment explaining what it does
                2. Define ALL objects mentioned in the story (characters, items, locations)
                3. Set up initial state that matches the story's beginning
                4. Define goal state that matches the story's objective
                5. Ensure consistency with the provided domain file
                6. Use proper PDDL syntax and typing
                
                Standard PDDL problem structure:
                (define (problem quest-problem)
                    (:domain quest-domain)
                (:objects
                    ; Define all story objects with their types
                    player - character ; The main character
                    location1 location2 - location ; Story locations
                    key sword - item ; Story items
                    )
                (:init
                    ; Initial world state - where story begins
                    (at player location1) ; Player starts here
                    (at key location2) ; Key is here
                    ; ... more initial conditions
                    )
                (:goal
                    ; Goal condition - what needs to be achieved
                    (and
                    (goal-achieved) ; Story objective completed
                    ; ... other goal conditions
                    )
                )
            )
                
                The problem MUST be solvable by a classical planner given the domain.
                Return ONLY the PDDL problem code, which begins with "(define (problem...", no other text.""" ), 
                MessagesPlaceholder(variable_name="examples"),
                ("user", "Story: {story_text}\n\nDomain PDDL: {domain_pddl}\n\nGenerate the corresponding PDDL problem file with detailed comments.")])
    
    formatted_prompt = prompt.invoke({"domain_pddl": state["domain_pddl"],
                                    "examples": [msg for example in example_messages_problem for msg in example],
                                    "story_text": state["story"]})
    
    print("3B# LLM per generare il PDDL problem invocato \n")
    response_llm = llm.invoke(formatted_prompt)
    problem_pddl = response_llm.content.strip()

    print("3B# Risposta: ", problem_pddl)

    problem_file = open(PROBLEM_PDDL_PATH, "w")
    problem_file.write(problem_pddl)
    problem_file.close()

    return {"problem_pddl": problem_pddl}


def validate_with_downward(
        domain_file:str = DOMAIN_PDDL_PATH,
        problem_file:str = PROBLEM_PDDL_PATH,
        downward_path:str = FASTDOWNWARD_PATH):
    """
       Valido i file PDDL utilizzando Fast Downward.
       Args:
            domain_file (str): Percorso al file PDDL del dominio.
            problem_file (str): Percorso al file PDDL del problema.
            downward_path (str): Percorso alla cartella di Fast Downward.
       Returns:
            bool: True se i file sono validi, False altrimenti.
            str: Log della validazione.
    """
    print("4# Validazione PDDL con Fast Downward...")
    command = [
        "python3", os.path.join(downward_path, "fast-downward.py"),
        domain_file,
        problem_file,
        "--search", 
        "astar(blind())"
    ]
    try:
        """result = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            timeout=10
        )"""
        result = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            timeout=30
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
    
def ValidatePDDL_node(state: QuestMasterState):
    is_valid, log = validate_with_downward()
    print(f"4# Validazione PDDL completata: {is_valid}, log: {log}")
    return {"is_valid": is_valid, "log": log}
    


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

#Genera un file PDDL dal documento di lore
def GeneraPDDL_node(state: QuestMasterState):
    llm = ChatOllama(model=MODEL, temperature=0.1)
    prompt = ChatPromptTemplate.from_messages([("system", fYou are a skilled PDDL problem and domain generator.
                Generate a complete PDDL problem and domain text representing the given story.
                Each line of PDDL code should be followed by a comment explaining what the line does. Example comment style: ; This line declares the predicate 'at'---.
                Do no insert other text at the begin or end of the response.
                Return the problem pddl first, then the domain pddl.
                Here some examples of domain.pddl file and problem.pddl file: ), 
                MessagesPlaceholder(variable_name="examples"),
                ("user", "Given the following narrative story: {story_text}. Generate the pddl problem file and the pddl domain file.")])
    
    formatted_prompt = prompt.invoke({"examples": [msg for example in example_messages for msg in example],
                                    "story_text": state["story"]})
    
    print("3# LLM per generare il PDDL invocato \n")
    response_llm = llm.invoke(formatted_prompt)
    response = response_llm.content

    print("3# Risposta: ", response)

    try:
        # Splitta domain e problem PDDL
        if "(define (domain" in response:
            problem_pddl, domain_pddl = response.split("(define (domain", 1)
            
            print("3# Problem: ", problem_pddl, "\n Domain: ", domain_pddl, "\n")

            problem_file = open("problem.pddl", "w")
            problem_file.write(problem_pddl)
            problem_file.close()

            domain_file = "(define (domain " + domain_file
            domain_file = open("domain.pddl", "w")
            domain_file.write(domain_pddl)
            domain_file.close()
        else:
            # fallback
            raise Exception("3# Splitting non avvenuto con successo. (define (problem non era presente")
        return {"domain_pddl": domain_pddl.strip(), "problem_pddl": problem_pddl.strip()}
    except Exception as e:
        return f"3# Errore nella generazione dei PDDL: {e} 
"""







# --- Costruzione del Grafo ---
builder = StateGraph(QuestMasterState)

# --- Aggiunta dei nodi al grafo ---

# 1. Carica il documento di lore
builder.add_node("carica_lore", CaricaLore_node)

# 2. Genera la storia
builder.add_node("genera_storia", GeneraStoria_node)


# 3. Genera i file PDDL
builder.add_node("genera_domain_pddl", GeneraPDDLdomain_node)
builder.add_node("genera_problem_pddl", GeneraPDDLproblem_node)
#builder.add_node("genera_pddl", GeneraPDDL_node)


# 4. Validazione del PDDL
builder.add_node("validate_pddl", ValidatePDDL_node)

#builder.add_node("reflect", ReflectAgent())
#builder.add_node("ask_author", ask_author_fn)


# --- Collegamento dei nodi ---
builder.add_edge(START, "carica_lore")
builder.add_edge("carica_lore", "genera_storia")
#builder.add_edge("genera_storia", "genera_pddl")
builder.add_edge("genera_storia", "genera_domain_pddl")
builder.add_edge("genera_domain_pddl", "genera_problem_pddl")
builder.add_edge("genera_problem_pddl", "validate_pddl")


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


def select_model():
    print("=== Seleziona il Modello ===")
    print("1 - llama3.2")
    print("2 - gpt-4o-mini")
    choice = input("> Inserisci il numero del modello da utilizzare (1 o 2): ")

    if choice == "1":
        return "llama3.2"
    elif choice == "2":
        return "gpt-4o-mini"
    else:
        print("Scelta non valida. Verrà utilizzato il modello di default: llama3.2")
        return "llama3.2"


# --- Avvia l'esecuzione ---
if __name__ == "__main__":
    # Vedo l'utente che modello vuole utilizzare
    MODEL = select_model()
    # Eseguo il grafo
    result = graph.invoke({"file_path": LORE_DOCUMENT_PATH})

