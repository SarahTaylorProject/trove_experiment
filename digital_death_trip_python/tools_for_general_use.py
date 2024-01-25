import os
from pathlib import Path

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')
    return()

def return_script_directory():
    script_directory = os.path.dirname(os.path.abspath(__file__))
    return(script_directory)

def return_parent_directory(input_directory):
    parent_directory = Path(input_directory).parent.absolute()
    return(parent_directory)