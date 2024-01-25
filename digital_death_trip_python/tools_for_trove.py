import os
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
    

def return_existing_trove_file_list(output_path_name, also_print=False, file_pattern="trove_result*"):
    existing_trove_file_list = []
    try:
        existing_trove_file_list = return_matching_file_names(input_path_name=output_path_name, 
            file_extension = "csv", 
            file_pattern = file_pattern)
        if (also_print == True):
            print_existing_trove_file_list(existing_trove_file_list)
        return(existing_trove_file_list)
    except:
        print("Encountered error in 'return_existing_trove_file_list'...")
        return(existing_trove_file_list)



def print_existing_trove_file_list(existing_trove_file_list):
    try:
        for file_name in existing_trove_file_list:
            search_town = return_trove_file_search_town(file_name)
            print(search_town)
            search_word = return_trove_file_search_word(file_name)
            print(search_word)
            # result_count = count_trove_search_results_from_csv(file_name)
            # print(f"{os.path.basename(file_name)}, {search_word}, {search_town}, {result_count} results)")
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

