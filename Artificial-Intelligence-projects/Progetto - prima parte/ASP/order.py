import re
import json
import subprocess

def run_clingo(command):
    """
    Executes a shell command to run clingo and generate the JSON output.

    Parameters:
    - command (str): The shell command to execute.

    Returns:
    - None
    """
    try:
        # Run the clingo command
        subprocess.run(command, shell=True, check=True)
        print("")
    except subprocess.CalledProcessError as e:
        print("")

def extract_values_from_json(file_path):
    """
    Extract the 'Value' entries from a given JSON file.

    Parameters:
    - file_path (str): Path to the JSON file.

    Returns:
    - List of values if successful, or an empty list if an error occurs.
    """
    try:
        # Read and load the JSON data
        with open(file_path, 'r') as file:
            data = json.load(file)

        # Extract the "Value" from the JSON structure
        value_list = data["Call"][0]["Witnesses"][0]["Value"]
        return value_list

    except (KeyError, json.JSONDecodeError, FileNotFoundError) as e:
        print(f"Error: {e}")
        return []

def estrai_squadre(partita):
    """
    Extract the team names from the match string.

    Parameters:
    - partita (str): The match string.

    Returns:
    - Formatted string with team names or an empty string if parsing fails.
    """
    # Use a regex to capture the names of the two teams
    match = re.match(r"partita\(\d+,(.+),(.+)\)", partita)
    if match:
        squadra1 = match.group(1)
        squadra2 = match.group(2)
        return f"{squadra1} - {squadra2}"
    return ""

def ordina_partite(partite):
    """
    Sort matches by the match day number.

    Parameters:
    - partite (list): List of match strings.

    Returns:
    - List of sorted match strings.
    """
    # Function to extract the match day number from the string
    def estrai_giornata(partita):
        match = re.match(r"partita\((\d+),", partita)
        if match:
            return int(match.group(1))
        return 0

    # Sort the list using the match day number
    partite_ordinate = sorted(partite, key=estrai_giornata)
    return partite_ordinate

def ordinaGiornate():
    """
    Sort and print matches by match days.
    """
    giornateArray = extract_values_from_json("calendario.json")
    sorted_partite = ordina_partite(giornateArray)
    count = 0
    for partita in sorted_partite:
        if count % 8 == 0:
            print("Giornata", int((count / 8) + 1))
        print("  ", estrai_squadre(partita))
        count += 1

# Command to run clingo and save output to calendario.json
#clingo_command_linux = "LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu clingo -t 7 --outf=2 calendario_competizione_sportiva.cl > calendario.json"
clingo_command = "clingo -t 7 --outf=2 calendario_competizione_sportiva.cl > calendario.json"
# Execute clingo command
run_clingo(clingo_command)

# Process and print sorted matches
ordinaGiornate()
