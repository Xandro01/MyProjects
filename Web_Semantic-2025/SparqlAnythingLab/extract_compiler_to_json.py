import requests
import json
import time
import pysparql_anything as sa
compilers_list = [
    "LambdaC", "CPython", "GCC",  "Rustc", "Swiftc", "Zend", "TSC", "Scalac",
    "Elixirc", "JuliaC", "Perl", "MySQL", "SwiftUIC", "CrystalC", "C# Compiler",
    "VBC", "JVM", "Javac"
]

def search_wikidata_entity(name):
    """Cerca l'entità Wikidata per il nome del compilatore"""
    search_url = "https://www.wikidata.org/w/api.php"
    params = {
        "action": "wbsearchentities",
        "search": name,
        "language": "en",
        "format": "json",
        "type": "item",
        "limit": 5
    }
    
    response = requests.get(search_url, params=params)
    if response.status_code == 200:
        data = response.json()
        if data.get("search"):
            # Prende il primo risultato che sembra essere un compilatore/software
            for result in data["search"]:
                if any(keyword in result.get("description", "").lower() 
                      for keyword in ["compiler", "programming", "software", "interpreter", "virtual machine"]):
                    return result["id"]
            # Se non trova nulla di specifico, prende il primo risultato
            return data["search"][0]["id"]
    return None

def get_wikidata_info(entity_id):
    """Estrae informazioni dall'entità Wikidata"""
    if not entity_id:
        return None
    
    url = f"https://www.wikidata.org/wiki/Special:EntityData/{entity_id}.json"
    response = requests.get(url)
    
    if response.status_code != 200:
        return None
    
    data = response.json()
    entity = data["entities"].get(entity_id, {})
    
    # Estrae la descrizione (P1813 o descrizione standard)
    description = ""
    if "descriptions" in entity and "en" in entity["descriptions"]:
        description = entity["descriptions"]["en"]["value"]
    
    # Estrae l'architettura target (P400)
    architecture = ""
    if "claims" in entity and "P400" in entity["claims"]:
        for claim in entity["claims"]["P400"]:
            if "mainsnak" in claim and "datavalue" in claim["mainsnak"]:
                arch_id = claim["mainsnak"]["datavalue"]["value"]["id"]
                arch_name = get_entity_label(arch_id)
                if arch_name:
                    architecture = arch_name
                    break
    
    return {
        "description": description,
        "architecture": architecture
    }

def get_entity_label(entity_id):
    """Ottiene l'etichetta di un'entità Wikidata"""
    url = f"https://www.wikidata.org/wiki/Special:EntityData/{entity_id}.json"
    response = requests.get(url)
    
    if response.status_code == 200:
        data = response.json()
        entity = data["entities"].get(entity_id, {})
        if "labels" in entity and "en" in entity["labels"]:
            return entity["labels"]["en"]["value"]
    return ""

def scrape_compiler_info(name):
    """Estrae informazioni del compilatore da Wikidata"""
    print(f" Cercando {name} su Wikidata...")
    
    # Cerca l'entità Wikidata
    entity_id = search_wikidata_entity(name)
    if not entity_id:
        print(f"   {name} non trovato su Wikidata")
        return None
    
    print(f" Trovato entity ID: {entity_id}")
    
    # Ottiene le informazioni dall'entità
    wikidata_info = get_wikidata_info(entity_id)
    if not wikidata_info:
        print(f"   Impossibile estrarre dati per {name}")
        return None
    
    return {
        "NomeStrumento": name,
        "Descrizione": wikidata_info["description"],
        "Architettura": wikidata_info["architecture"]
    }

"""
compiler_data = []
for compiler_name in compilers_list:
    print(f"🔍 Processando {compiler_name}...")
    info = scrape_compiler_info(compiler_name)
    
    if info and info["Descrizione"]:
        compiler_data.append(info)
        print(f"   {compiler_name} - Architettura: {info['Architettura'] or 'Non trovata'}")
        print(f"     Descrizione: {info['Descrizione'][:100]}...")
    else:
        print(f"  {compiler_name} - Dati insufficienti")
    
    time.sleep(1)  # Rate limiting per Wikidata

# Salvataggio del file JSON
with open("Data/compiler.json", "w", encoding="utf-8") as f:
    json.dump(compiler_data, f, ensure_ascii=False, indent=4)

print(f"\n Salvati {len(compiler_data)} compilatori in 'Data/compiler.json'.")
"""


sparql_anything = sa.SparqlAnything()

sparql_anything.run(query='query_sparql/compiler.sparql',output='output_turtle_sparqlA/Compiler.ttl',format='ttl')