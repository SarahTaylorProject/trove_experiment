import os
import requests
from tools_for_general_use import *

def return_trove_key(trove_key_file="my_trove.txt", trove_key_directory="keys"):
    # Looks in various locations for trove key file
    # Returns None if unsuccessful, returns key if successful
    try:
        trove_key = None
        script_directory = return_script_directory()
        parent_directory = return_parent_directory(script_directory)

        trove_key_file_path = os.path.join(trove_key_directory, trove_key_file)
        
        trove_key = try_read_trove_key_file(trove_key_file_path)
        
        if (trove_key == None):
            try_directory = os.path.join(parent_directory, trove_key_directory)
            trove_key_file_path = os.path.join(try_directory, trove_key_file)
            trove_key = try_read_trove_key_file(trove_key_file_path)
        if (trove_key == None):
            trove_key_file_path = trove_key_file
            trove_key = try_read_trove_key_file(trove_key_file_path)
        if (trove_key == None):
            trove_key_file_path = os.path.join(parent_directory, trove_key_file)
            trove_key = try_read_trove_key_file(trove_key_file_path)

        return(trove_key)
    except:
        print(f"Error with finding Trove key {trove_key_file} in {trove_key_directory}")
        return(None)


def try_read_trove_key_file(trove_key_file_path="my_trove.txt"):
    try:
        with open(trove_key_file_path, 'r') as f:
            trove_key = f.readline()
            print(f"Found Trove key")
        return(trove_key)
    except:
        return(None)
    

def return_existing_trove_result_files(output_path_name, also_print=False, file_pattern="trove_result*"):
    existing_trove_result_files = []
    try:
        existing_trove_result_files = return_matching_file_names(input_path_name=output_path_name, 
            file_extension = "csv", 
            file_pattern = file_pattern)
        if (also_print == True):
            print_existing_trove_result_files(existing_trove_result_files)
        return(existing_trove_result_files)
    except:
        print("Encountered error in 'return_existing_trove_result_files'...")
        return(existing_trove_result_files)


def print_existing_trove_result_files(existing_trove_result_files):
    try:
        for file_name in existing_trove_result_files:
            search_town = return_trove_file_search_town(file_name)
            search_word = return_trove_file_search_word(file_name)
            result_count = count_trove_search_results_from_csv(file_name)
            print(f"{os.path.basename(file_name)}: {search_town} {search_word} ({result_count} records)")
    except:
        return()


def return_trove_file_search_town(input_trove_file, search_town_field=1, delimiter=","):
    """
    Returns the town name for a Trove CSV file, by using the first row 
    This is marginally easier than inferring the search town from the file name
    If errors encountered, returns blank string
    If successful, returns the search town name from the Trove search result CSV file (defaults to field 1)
    """
    search_town = ''
    try:
        first_line = return_first_line_of_csv_file(input_trove_file)
        if (first_line != None):
            search_town = first_line[search_town_field]
        return(search_town)
    except:
        print(f"Error encountered in 'return_trove_file_search_town', returning {search_town}...")
        return(search_town)


def return_trove_file_search_word(input_trove_file, search_word_field=0, delimiter=","):
    """
    Returns the search word for a Trove CSV file, by using the first row 
    This is marginally easier than inferring the search word from the file name
    If errors encountered, returns blank string
    If successful, returns the search town name from the Trove search result CSV file (defaults to field 1)
    """
    search_word = ''
    try:
        first_line = return_first_line_of_csv_file(input_trove_file)
        if (first_line != None):
            search_word = first_line[search_word_field]
        return(search_word)
    except:
        print(f"Error encountered in 'return_trove_file_search_word', returning {search_word}...")
        return(search_word)


def count_trove_search_results_from_csv(input_trove_file):
    result = return_line_count_of_csv_file(input_trove_file)
    return(result)


def search_for_matching_trove_file(existing_trove_result_files, search_town, search_word='', search_word_field=0, search_town_field=1):
    """
    Looks for a matching Trove file from list: the first (if any) that matches the search_town and search_word
    Can save an unnecessary internet search if file already exists
    Will only match the search_word if it's non-blank (thus making it possible to search for any files for the search_town)
    """
    matching_trove_file = ''
    try:
        print(f"\nSearching existing Trove files for {search_town}")
        for current_file_name in existing_trove_result_files:
            current_town = return_trove_file_search_town(input_trove_file=current_file_name, search_town_field=search_town_field)
            if (current_town == search_town):
                print(f"Matching town in: #{current_file_name}")
                if (search_word != ''):
                    print(f"Will also check for search word {search_word}")
                    current_word = return_trove_file_search_word(input_trove_file=current_file_name, search_word_field=search_word_field)
                else:
                    current_word = search_word
            
            if (current_town.upper() == search_town.upper()):
                if (current_word.upper() == search_word.upper()):                
                    print(f"Matching file: #{current_file_name}")
                return(current_file_name)
  
        return(matching_trove_file)
    except:
        print(f"Error encountered in 'search_for_matching_trove_file', returning empty list...")
        return(matching_trove_file)

def fetch_trove_search_result(trove_key='', search_town='', search_word='', 
                              trove_search_base="https://api.trove.nla.gov.au/v3/result?",
                              search_term_divider='%22', search_term_joiner='%20',
                              search_category='newspaper',
                              result_s='%2A',
                              result_n=20,
                              result_sortby='relevance',
                              result_bulkharvest='false',
                              result_reclevel='brief',
                              result_encoding='json'):
    #https://api.trove.nla.gov.au/v3/result?category=newspaper
    #&q=elmore%20tragedy&s=%2A&n=20&sortby=relevance&bulkHarvest=false&reclevel=brief&encoding=xml

    trove_search_result = None

    search_word_list = []
    for input_word in [search_town, search_word]:
        current_word = remove_nuisance_characters_from_string(input_word)
        current_word = current_word.replace(' ', search_term_joiner)
        if (len(current_word) > 0):
            search_word_list.append(current_word)

    search_q = search_term_divider.join(search_word_list)
    print(search_q)

    request_list = []
    request_list.append([f"key={trove_key}"])
    request_list.append([f"q={search_q}"])
    request_list.append([f"category={search_category}"])
    request_list.append([f"s={result_s}"])
    request_list.append([f"n={result_n}"])
    request_list.append([f"sortby={result_sortby}"])
    request_list.append([f"bulkHarvest={result_bulkharvest}"])
    request_list.append([f"reclevel={result_reclevel}"])
    request_list.append([f"encoding={result_encoding}"])

    trove_request = trove_search_base + '&'.join(request_list)
    print(trove_request)
    try:
        trove_search_result = requests.get(trove_request)
        print(trove_search_result)
    except:
        print("Error getting API results")
        return(trove_search_result)
