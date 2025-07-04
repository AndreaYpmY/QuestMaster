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
from langchain_core.tools import tool






# ----- VARIABILI -----
MODEL="llama3.2" #gpt-4o-mini o llama3.2
TEMPERATURE_STORY=0.6
TEMPERATURE_PDDL_DOMAIN=0
TEMPERATURE_PDDL_PROBLEM=0
TEMPERATURE_PDDL_REFLECTION=0
TEMPERATURE_HTML=0

FASTDOWNWARD_PATH = "../downward"  
LORE_DOCUMENT_PATH = "lore_document.txt"  
DOMAIN_PDDL_PATH = "domain.pddl" 
PROBLEM_PDDL_PATH = "problem.pddl" 
STORY_PATH = "storia.txt"
PLAN_PATH = "sas_plan"

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
    is_valid_story: bool
    domain_pddl: str
    problem_pddl: str
    is_valid: bool
    log: str
    suggestion: list
    acepted_suggestion: list

def get_model(temp:float):
    """
    Restituisce il modello da utilizzare per la generazione della storia e del PDDL.
    """
    print(f"> Utilizzo il modello {MODEL} con temperatura {temp}\n")
    if MODEL == "gpt-4.1-mini":
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
        If is impossible to create the story with the given lore document and respect the constraints, returns ONLY the word "IMPOSSIBLE".

        Generate the COMPLETE story structure now and do not insert the validation checklist or summary at the end."""),
    ("user", "Lore Document: {lore_text}\nGenerate the complete structured interactive story respecting ALL constraints.")])
    
    print("2# LLM invocato per la creazione della storia \n")
    formatted_prompt = prompt.invoke({"lore_text": state["lore"]})
    response_llm = llm.invoke(formatted_prompt)
    response = response_llm.content

    print("--- 2# ---\n "+response)

    if response == "IMPOSSIBLE" or "IMPOSSIBLE" in response:
        return {"is_valid_story": False}
    else:
        storia_file = open(STORY_PATH, "w")
        storia_file.write(response)
        storia_file.close()
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

    print(response + "\n")

    lore_file = open(LORE_DOCUMENT_PATH, "w")
    lore_file.write(response)
    lore_file.close()

    return {"lore": response}

"""
Example of structure of the expected output:
                # Quest Description
                Commander Elara Quinn leads a mission aboard the Starship Echo to investigate a silent research station orbiting Virella-7. Once inside, she finds the power down, doors sealed, and signs of something unknown lurking within. Her goal: reactivate the station, retrieve alien research data, and make it out alive.

                Initial State:
                -The Echo is docked to the station.
                -All doors are sealed.
                -Power is critically low.
                -Reactor is offline.
                -Alien artifact is contained in Lab 3.
                -Only Elara is inside the station at the start.

                Goal:
                -The main reactor is reactivated.
                -The alien artifact is analyzed.
                -The research data is extracted.
                -Elara returns safely to the ship.

                Obstacles:
                -Sealed or damaged doors requiring power reroutes or manual override.
                -Rogue maintenance drones behaving erratically.
                -Sections of the station depressurized.
                -Psychological effects from prolonged exposure to the alien artifact.
                -Sabotaged subsystems from the original crew

                Branching Factor:
                - Min: 2
                - Max: 3

                Depth Constraints:
                - Min: 2
                - Max: 6    
"""

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
    
def ValidatePDDL_node(state: QuestMasterState):
    is_valid, log = validate_with_downward()
    print(f"4# Validazione PDDL completata: {is_valid}, log: {log} \n")
    return {"is_valid": is_valid, "log": log}
    



# ---Reflection pattern ---
def reflection_node(state: QuestMasterState):
    llm= get_model(TEMPERATURE_PDDL_REFLECTION)

    prompt = ChatPromptTemplate.from_messages([("system", f"""You are a PDDL expert and logical reasoning agent.
            Analyze the PDDL files which you can found at the end, and reflect on these files to detect issues, logical inconsistencies, narrative gaps and suggest improvements.
                                                
            Follow these steps carefully: 
                1. Make syntax validation:
                    Check whether the two files are SYNTACTICALLY CORRECT:
                        - The domain.pddl file must correctly define:
                            - (define (domain ...))
                            - :predicates, :action, :parameters, :precondition, :effect, etc.
                        - The problem.pddl file must include:
                            - (define (problem ...))
                            - (domain ...), :objects, :init, :goal, etc.
                        - Missing parentheses
                        - Undeclared or mismatched names
                        - Invalid PDDL constructs

                2. Make semantic validation:
                    If syntax is valid, analyze whether the GOAL IS LOGICALLY ACHIEVABLE:
                        - Is the goal state reachable based on the initial state and available actions?
                        - Are the objects, predicates, and actions in the domain properly used to progress toward the goal?
                        - Are there missing actions or predicates that prevent reaching the goal?

                3. Generate a structured output
                    Provide a structured report with a bullet list of problems followed by the possible fixes, separated by type and separate each output with "---"
                            - [ ] Briefly describe each syntax error (e.g., "Missing closing parenthesis in `:action move`") and suggest a fix for each issue.
                            - [ ] If the planner cannot reach the goal, explain why (e.g., There is no action that makes door-open true) and suggest changes to the domain or problem to make the goal achievable.
            
            Return ONLY the bullet list of problems followed by the possible fixes and separate each output with "---", no other text.
            Return at max the 10 most important problems.
                                                
            Example of expected output:
                    - PROBLEM: "Missing closing parenthesis on line 23"; SUGGESTION: "close the parenthesis on line 23"; ---
                    - PROBLEM: "Predicate 'at' is used but not declared in :predicates"; SUGGESTION: "Declare the predicate 'at' in :predicates"; ---
                    - PROBLEM: "No action makes the goal (at robot room2) achievable; SUGGESTION: "Add a 'move' action with precondition (at ?r ?from) and effect (not (at ?r ?from)) (at ?r ?to)"; ---
            """),
            
            
            ("user", "Please analyze the following PDDL domain and problem files and suggest changes to fix the syntax and logical errors, so that the PDDL is solvable by a classical planner. Domain PDDL: {domain_pddl} \n Problem PDDL: {problem_pddl}")])
    
    formatted_prompt = prompt.invoke({"domain_pddl": state["domain_pddl"], "problem_pddl": state["problem_pddl"]})
    
    print("4# LLM per riflettere sui PDDL e correggerli \n")
    response_llm = llm.invoke(formatted_prompt)
    response = response_llm.content.strip()

    try:
        suggestion = response.split("---")
        del suggestion[-1]
        return {"suggestion": suggestion}
    except Exception as e:
        return f"4# Errore nella ricezione dei suggerimenti. Separatore non corretti: {e}"



def human_in_the_loop_node(state: QuestMasterState):
    print("5# Proposte di modifica: \n")
    
    suggestion = state["suggestion"]
    accepted_suggestion = []
    for s in suggestion:
        print("> " + s + "\n")
        u_input = input("Vuoi accettare questa modifica? (y/n): ")
        if u_input == "y":
            accepted_suggestion.append(s)
            
    return {"acepted_suggestion": accepted_suggestion}



def fix_pddl_node(state: QuestMasterState):
    print("6# Correzione PDDL tramite i suggerimenti \n")

    llm= get_model(TEMPERATURE_PDDL_REFLECTION)

    prompt = ChatPromptTemplate.from_messages([("system", f"""You are a PDDL expert generator agent.
                Modify the domain and problem PDDLs accordingly to fix these issues, focus on preserving the original structure and content as much as possible, making minimal necessary changes for correctness and solvability.
                Use the suggestions to correct all detected problems, including syntax errors and logical inconsistencies, so that:
                    - The PDDL syntax is fully valid.
                    - The problem is solvable: the goal is reachable from the initial state using the defined actions.                        
                        
                Return ONLY the PDDL domain and problem, no other text at begin or end of the PDDL for each one.
                Return first the PDDL domain and then the PDDL problem.
                Separate the PDDLs by "---OTHER---"."""),
            ("user", "Applay the following suggestion: {suggestion} to the PDDL domain and problem files, in ordert to correct the issue and make the PDDLs solvable by a classical planner. Separate the PDDLs by \"---OTHER---\" \n Domain PDDL: {domain_pddl} \n Problem PDDL: {problem_pddl}")])
    
    formatted_prompt = prompt.invoke({"domain_pddl": state["domain_pddl"], "problem_pddl": state["problem_pddl"], "suggestion": state["acepted_suggestion"]})
    
    print("6A# Generazione nuovi PDDL \n")
    response_llm = llm.invoke(formatted_prompt)
    response = response_llm.content.strip()

    print("Nuovi PDDL: " + response + "\n")

    try:
        if "---OTHER---" in response:
            domain_pddl, problem_pddl = response.split("---OTHER---", 1)
                
            print("6B# Problem: ", problem_pddl, "\n 6C# Domain: ", domain_pddl, "\n")

            problem_file = open("problem.pddl", "w")
            problem_file.write(problem_pddl)
            problem_file.close()


            domain_file = open("domain.pddl", "w")
            domain_file.write(domain_pddl)
            domain_file.close()

            return {"domain_pddl": domain_pddl.strip(), "problem_pddl": problem_pddl.strip()}
        else:
            raise Exception("3# Splitting non avvenuto con successo. '------' non era presente")
    except Exception as e:
        return f"3# Errore nella generazione dei PDDL: {e}"


def carica_pddl_node(state: QuestMasterState):
    domain_pddl =""
    problem_pddl =""

    with open("domain.pddl", 'r') as f:
            print("1# Domain PDDL aperto con successo \n")
            domain_pddl = f.read()
            f.close()

    with open("problem.pddl", 'r') as f:
            print("1# Problem PDDL aperto con successo \n")
            problem_pddl = f.read()
            f.close()

    return {"domain_pddl": domain_pddl.strip(), "problem_pddl": problem_pddl.strip()}

""" 
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



def generate_HTML_node(state: QuestMasterState):
    lore = problem_pddl = domain_pddl = story = plan = ""

    with open(LORE_DOCUMENT_PATH, 'r') as f:
        print("# Lore document aperto con successo \n")
        lore = f.read()
    with open(DOMAIN_PDDL_PATH, 'r') as f:
        print("# Domain PDDL aperto con successo \n")
        domain_pddl = f.read()
    with open(PROBLEM_PDDL_PATH, 'r') as f:
        print("# PROBLEM PDDL aperto con successo \n")
        problem_pddl = f.read()
    with open(STORY_PATH, 'r') as f:
        print("# Storia aperto con successo \n")
        story = f.read()
    with open(PLAN_PATH, 'r') as f:
        print("# Plan aperto con successo \n")
        plan = f.read()


    print("7# Generazione HTML \n")

    llm= get_model(TEMPERATURE_HTML)

    prompt = ChatPromptTemplate.from_messages([("system", f"""You are a narrative game engine and HTML, CSS and Javascript expert generator agent that generates fully playable interactive HTML adventure games.
            Your output must be a complete, valid, and self-contained HTML file playable in any modern web browser.
            The story is a sci-fi interactive quest based on a lore document, story text, PDDL domain and problem files, and a sequence of plan steps.
            You must produce:
                - Clear narrative with dialogues scenes for each step that describe the state using the story
                - Interactive buttons to progress through the story. If there are multiple choise, add a button for each choise and cosider the followed path
                - A starting page with lore and a "Start Game" button
                - A final scene with a "Play Again" button to restart
            Use only HTML, CSS, and JavaScript; no external libraries or dependencies.
            The style should be minimalist with a dark theme and readable fonts.
            Return ONLY the complete HTML document; no explanations or extra text."""),
            ("user", "Here is the Lore document describing the story world and quest:{lore} \n Here is the story describing the narrative: {story} \n Here is the PDDL Domain file: {domain} \n Here is the PDDL Problem file: {problem} \n Here is the ordered list of plan steps generated by the classical planner: {plan}." +
            "Please generate the FULL interactive HTML game, playable entirely in the frontend, with CSS and Javascript.")])
    
    formatted_prompt = prompt.invoke({"lore": lore, "story": story, "domain": domain_pddl, "problem": problem_pddl, "plan": plan})
    

    response_llm = llm.invoke(formatted_prompt)
    response = response_llm.content.strip()

    print("HTML generato: " + response + "\n")

    template = open("gioco.html", "w")
    template.write(response)
    template.close()

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
#builder.add_node("genera_pddl", GeneraPDDL_node)


# 4. Validazione del PDDL
builder.add_node("validate_pddl", ValidatePDDL_node)

# 5. Pattern reflection per aggiustare il PDDL
builder.add_node("reflect", reflection_node)
builder.add_node("human", human_in_the_loop_node)
builder.add_node("fix", fix_pddl_node)


#Prova per partire con il programma dalla reflection
#builder.add_node("prova_dopo", carica_pddl_node)


#6. Generazione HTML
builder.add_node("genera_HTML", generate_HTML_node)




# --- Collegamento dei nodi ---
builder.add_edge(START, "carica_lore")
#builder.add_edge("carica_lore", "genera_storia")

"""
builder.add_conditional_edges("genera_storia",
    lambda x: "valid" if x["is_valid_story"] else "invalid",
    {
        "valid": "genera_domain_pddl",
        "invalid": "invalid_story"
    })
"""
    
#builder.add_edge("invalid_story", "genera_storia")
#builder.add_edge("genera_domain_pddl", "genera_problem_pddl")
#builder.add_edge("genera_problem_pddl", "validate_pddl")



#builder.add_edge(START, "prova_dopo")
#builder.add_edge("prova_dopo", "validate_pddl")

"""
builder.add_conditional_edges("validate_pddl", 
    lambda x: "valid" if x["is_valid"] else "invalid",
    {
        "valid": END,
        "invalid": "reflect"
    })
"""

#builder.add_edge("reflect", "human")
#builder.add_edge("human", "fix")
#builder.add_edge("fix", "validate_pddl")

builder.add_edge("carica_lore", "genera_HTML")
builder.add_edge("genera_HTML", END)



# --- Compila il grafo ---
graph = builder.compile()
print("Costruzione del grafo avvenuta con successo")


def select_model():
    print("=== Seleziona il Modello ===")
    print("1 - llama3.2")
    print("2 - gpt-4.1-mini")
    choice = input("> Inserisci il numero del modello da utilizzare (1 o 2): ")

    if choice == "1":
        return "llama3.2"
        #return "deepseek-r1:14b"
    elif choice == "2":
        return "gpt-4.1-mini"
    else:
        print("Scelta non valida. Verrà utilizzato il modello di default: llama3.2")
        return "llama3.2"


# --- Avvia l'esecuzione ---
if __name__ == "__main__":
    # Vedo l'utente che modello vuole utilizzare
    MODEL = select_model()
    # Eseguo il grafo
    result = graph.invoke({"file_path": LORE_DOCUMENT_PATH})

