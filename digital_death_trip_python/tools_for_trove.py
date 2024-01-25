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
    

