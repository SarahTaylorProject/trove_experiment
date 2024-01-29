import csv
import random

from tools_for_general_use import *

def return_town_list_with_user_input(speed, try_say,
        town_directory='town_lists',
        vicmap_file_name='vic_and_border_locality_list.csv',
        australian_cities_file_name='australian_cities_list.csv'):
    town_list = []
    try:
        default_source_choice='P'

        source_options = ['\n']
        source_options.append("Type 'P' for PTV stop files in Victoria (DEFAULT); OR")
        source_options.append("Type 'V' for VicMap localities in Victoria and border New South Wales; OR")
        source_options.append("Type 'A' for the Australian Cities database; OR")
        source_options.append("Type 'EXIT' to cancel")
        # IDEA: Include option for all
        prompt_text = "Which source would you like to use?\n" + "\n-\t".join(source_options) + "\n\n"
        source_choice = get_user_input(prompt_text=prompt_text)

        if (len(source_choice) == 0):
            source_choice = default_source_choice
        else:
            source_choice = source_choice.strip()[0].upper()
        print(source_choice)
        if (source_choice == 'P'):
            town_list = return_town_list_from_ptv_stop_files(town_directory=town_directory)
        elif (source_choice == 'V'):
            town_list = return_town_list_from_single_file(town_file_name=vicmap_file_name,
                town_directory=town_directory,
                town_file_type='vicmap',
                town_field_num=3)
        elif (source_choice == 'A'):
            town_list = return_town_list_from_single_file(town_file_name=australian_cities_file_name,
                town_directory=town_directory,
                town_file_type='other',
                town_field_num=0)        
        if (len(town_list) == 0):
            say_something("I'm sorry, I couldn't find any towns, please check source choice and try again.", try_say=try_say, speed=speed)

        return(town_list)
    
    except:
        print("Error encountered ...")
        return(town_list)


def return_town_list_from_single_file(town_file_name,
        town_directory, town_file_type='ptv_stops', town_field_num=1):
    """
    Returns a dictionary of town names from a single file, can be of varying type
    """
    town_list = []
    try:
        town_file_path = os.path.join(town_directory, town_file_name)
        print(f"Attempting to make town list from file {town_file_path}")
        with open(town_file_path, "r") as f:
            csv_data = list(csv.reader(f))[1:]
            for row in csv_data:
                print(row)
                current_town = None
                if (town_file_type == 'ptv_stops'):
                    current_town = extract_town_string_from_ptv_stop_string(input_string=row[town_field_num])
                else:
                    current_town = row[town_field_num].title()
                print(current_town)
                if (current_town != None):
                    town_list.append(current_town)
        # IDEA/CHOICE: sort? unique?
        return(town_list)
    except:
        print(f"Encountered error in 'return_town_list_from_single_file'")
        return(town_list)
  

def return_town_list_from_ptv_stop_files(town_directory='', file_pattern='*stops*'):
    town_list = []
    try:
        stop_files = return_matching_file_names(input_path_name=town_directory, 
            file_extension = "txt", 
            file_pattern = file_pattern)
        for stop_file_name in stop_files:
            print(f"Current stop file: {stop_file_name}")
            current_town_list = return_town_list_from_single_file(file_name=stop_file_name, 
                town_file_type = 'ptv_stops', 
                town_field_num = 1)
            print(len(current_town_list))
            if (len(current_town_list) > 0): 
                town_list.extend(current_town_list)
            print(len(town_list))
        return(town_list)
    except:
        print("Error encountered in 'return_town_list_from_ptv_stop_files'...")
        return(town_list)


def extract_town_string_from_ptv_stop_string(input_string, start_divider="(", end_divider=")"):
    result = False
    try:
        input_string_parts = input_string.split(start_divider)
        if (len(input_string_parts) != 2):
            return(result)
        else:
            target_string = input_string_parts[1]
            town_string = target_string.split(end_divider)[0]
            return(town_string)
    except:
        print(f"Encountered error in extract_town_string_from_gfts_stops_stop_string, input {input_string}, will skip...")
        return(result)


def select_random_town_with_user_input(town_list, try_say, speed):
    """
    Assists with near-random choice of town
    Enters a loop that will continue if the user says 'n' to the random selection/s
    Only returns when either a) user enters 'EXIT', or b) user presses a value other than 'n'
    """
    random_town = None
    try:
        say_something(f"I found {len(town_list)} unique towns in this data.", try_say=try_say, speed=speed)
        try_again = True
        while (try_again == True):
            random_town = random.choice(town_list)
            say_something(f"\nMy random town choice is {random_town}", try_say=try_say, speed=speed)      
            say_something("\nWhat do you think?", try_say=try_say, speed=speed)
            user_input = get_user_input(prompt_text = "Enter 'n' to try again, \nEnter 'exit' to cancel and exit, \nEnter any other key to continue with this town choice...")
            if (user_input.upper() == 'EXIT'):
                return(random_town)
            elif (user_input.upper() == 'N'):
                try_again = True
            else:
                try_again = False
                print(f"Ok. Will return {random_town}")
        return(random_town)
    except:
        print("Error encountered in 'select_random_town_with_user_input'...")
        return(random_town)



