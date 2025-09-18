
import csv
import datetime
from SPARQLWrapper import SPARQLWrapper, JSON
import pysparql_anything as sa
import os
import io

# Function to query Wikidata for programming language information
def query_programming_language_data(programming_language_name):
    """
    Queries Wikidata to get information about.
    Args:
        programming_language_name (str): The name of the programming language to query
    Returns:
        tuple: A tuple containing the programming language's author, logo, and based on properties.
               If the data is not found, returns ("None").
    """
    sparql = SPARQLWrapper("https://query.wikidata.org/sparql")  # Initialize SPARQL endpoint

 
    query = f"""
        SELECT ?authorLabel ?logo ?basedOnLabel WHERE {{
           
            ?programming_language rdfs:label "{programming_language_name}"@en.
            
            OPTIONAL {{ ?programming_language wdt:P178 ?author. }}
            OPTIONAL {{ ?programming_language wdt:P154 ?logo. }}
            OPTIONAL {{ ?programming_language wdt:P144 ?basedOn. }}

            SERVICE wikibase:label {{ bd:serviceParam wikibase:language "en". }}
        }}
        LIMIT 1
        """


    sparql.setQuery(query)  # Set the query to the SPARQL wrapper
    sparql.setReturnFormat(JSON)  # Set the return format to JSON
    results = sparql.query().convert()  # Execute the query and convert results to JSON

    if results["results"]["bindings"]:  # Check if any results were returned
        result = results["results"]["bindings"][0]
        author = result["authorLabel"]["value"] if "authorLabel" in result else "None"
        logo = result["logo"]["value"] if "logo" in result else "None"
        based_on = result["basedOnLabel"]["value"] if "basedOnLabel" in result else "None"
        return author, logo, based_on  # Extract the author, logo, and based on properties
    else:
        return "None", "None", "None"   

def paradigms_column_refactoring(reader):
    
    paradigm_fields = [
        "EventOriented Paradigm",
        "Functional Paradigm",
        "Imperative Paradigm",
        "Logic Paradigm",
        "ObjectOriented Paradigm",
        "Procedural Paradigm",
        "Structural Paradigm",
        "Declarative Paradigm"
    ]
    # Create a list of new field names for the expanded Paradigms column
    new_fieldnames = ["Informazioni cronologiche","Name","Description","Logo","EventOriented Paradigm","Functional Paradigm","Imperative Paradigm","Logic Paradigm","ObjectOriented Paradigm","Procedural Paradigm","Structural Paradigm","Declarative Paradigm","Originates From which Language","Compilation typing","Execution  typing","Compiler Name","Interpreter Name","Creator","Is semi-compiled?"]
    # Lista per le righe trasformate
    transformed_data = []

    for row in reader:
        new_row = {
            "Informazioni cronologiche": row["Informazioni cronologiche"],
            "Name": row["Name"],
            "Description": row["Description"],
            "Logo": row["Logo"],
            "Originates From which Language": row["Originates From which Language"],
            "Compilation typing": row["Compilation typing"],
            "Execution  typing": row["Execution  typing"],
            "Compiler Name": row["Compiler Name"],
            "Interpreter Name": row["Interpreter Name"],
            "Creator": row["Creator"],
            "Is semi-compiled?": row["Is semi-compiled?"]
        }

        # Paradigmi presenti
        present_paradigms = set(p.strip() for p in row["Paradigms"].split(";") if p.strip())

        # Aggiunge i nuovi campi
        for paradigm in paradigm_fields:
            new_row[paradigm] = "Yes" if paradigm in present_paradigms else "No"

        transformed_data.append(new_row)

    # Scrive i dati trasformati in un oggetto StringIO
    output = io.StringIO()
    writer = csv.DictWriter(output, fieldnames=new_fieldnames)
    writer.writeheader()
    writer.writerows(transformed_data)
    output.seek(0)  # Riporta il puntatore all'inizio per poter leggere

    # Restituisce un nuovo reader
    return csv.DictReader(output)

# Function to enrich a CSV file with additional author information, patric pagliaccio
def get_miss_value(csv_file_path, output_file_name):
    """
    Reads an input CSV file, check "Creatore", "Deriva da", "logo" field, every time once of them miss fill data with data fetch from Wikidata,
    return modified CSV file.

    Args:
        input_file (str): Path to the input CSV file.
        output_file (str): Path to the output CSV file.
    """
    # Open the input CSV file for reading
    with open(csv_file_path, mode='r', encoding='utf-8') as input_csv_file:
        reader = csv.DictReader(input_csv_file)  # Read the CSV file into a dictionary
        reader = paradigms_column_refactoring(reader)  # Call the function to refactor the Paradigms column
        enriched_rows = []  # List to store enriched rows

        for row in reader:  # Iterate through each row in the CSV file
            programming_language_name = row["Name"]  # Get the programming language name from the row

            # Query Wikidata for programming language information
            author, logo, based_on = query_programming_language_data(programming_language_name)
            print (f"Processing {programming_language_name}: Author: {author}, Logo: {logo}, Based on: {based_on}")
            # Update the row with the queried data
            if (not author == "None" and row["Creator"] == ""):
                row["Creator"] = author
            if (not logo == "None" and row["Logo"] == ""):
                row["Logo"] = logo
            if (not based_on == "None" and row["Originates From which Language"] == ""):
                row["Originates From which Language"] = based_on
            # Append the enriched row to the list
            enriched_rows.append(row)
            
    
    #create output directory if not exist
    if not os.path.exists("Data"):
        os.makedirs("Data")
    
    
    # Write the enriched rows to the output CSV file with the output_file_name as the name
    with open(f"Data/{output_file_name}", mode='w', encoding='utf-8', newline='') as output_csv_file:
        fieldnames = reader.fieldnames
        writer = csv.DictWriter(output_csv_file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(enriched_rows)

            


"""
get_miss_value(
    csv_file_path= "Data/programming_language_form.csv",  
    output_file_name = "programming_language_form_filled.csv" 
)
"""

sparql_anything = sa.SparqlAnything()

sparql_anything.run(query='query_sparql/programming_language_google_form.sparql',output='output_turtle_sparqlA/pl_google_form_KG.ttl',format='ttl')


