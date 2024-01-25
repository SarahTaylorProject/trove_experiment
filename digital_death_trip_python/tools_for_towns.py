import csv

from tools_for_general_use import *

def return_existing_stop_file_name_list(town_path_name):
    stop_file_name_list = []
    try:
        print(town_path_name)
        stop_file_name_list = return_matching_file_names(input_path_name=town_path_name, 
            file_extension = "txt", 
            file_pattern = "stops*")
        return(stop_file_name_list)
    except:
        print(f"Encountered error in 'return_existing_stop_file_name_list'")
        return(stop_file_name_list)

def return_town_dictionary_from_stop_file_name_list(stop_file_name_list):
    town_dictionary = {}
    try:
        for stop_file_name in stop_file_name_list:
            print(f"Current PTV stop file: {stop_file_name}")
            current_town_dictionary = return_town_dictionary_from_single_file(stop_file_name = stop_file_name, 
                town_file_type = 'ptv', 
                town_field_num = 1, 
                lat_field_num = 2, 
                long_field_num = 3)
            if (current_town_dictionary != False): 
                town_dictionary.update(current_town_dictionary)
    
        print(f"Finished. Town count: {len(town_dictionary)}")
        town_dictionary_sorted = sorted(town_dictionary)
        return(town_dictionary_sorted)
    except:
        print("Error encountered in 'return_town_dictionary_from_stop_file_name_list'...")
        return(town_dictionary)


def return_town_dictionary_from_single_file(file_name,
        town_file_type='ptv',
        town_field_num=1, lat_field_num=2, long_field_num=3,
        select_field_num=None, select_field_value=None):
    town_dictionary = {}
    try:
        print(f"Attempting to make town dictionary from file {file_name}")
        with open(file_name, "r") as f:
            csv_data = list(csv.reader(f))[1:]
            for row in csv_data:
                if (town_file_type == 'ptv'):
                    town_name = extract_town_string_from_ptv_stop_string(row[town_field_num])
                elif (town_file_type == 'vicmap'):
                    town_name = extract_town_string_from_vicmap_string(row[town_field_num])
                else:
                    town_name = row[town_field_num]
        
        if (select_field_num != None):
            if (row[select_field_num] != select_field_value):
               town_name = False

        if (town_name != False):
            town_dictionary[town_name] = [float(row[lat_field_num]), float(row[long_field_num])]
        
        print_town_dictionary(town_dictionary)
        return(town_dictionary)

    except:
        print(f"Encountered error in return_town_dictionary_from_single_file...")
        return(town_dictionary)



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
        print(f"Encountered error in extract_town_string_from_ptv_stop_string, input {input_string}, will skip...")
        return(result)


def extract_town_string_from_vicmap_string(input_string):
    try:
        output_string = input_string.split("(")[0]
        output_string = output_string.title()
        return(output_string)
    except:
        return(input_string)


def print_town_dictionary(town_dictionary):
    try:
        for key, item in town_dictionary.items():
           print(item)
           # town? coordinates?
    except:
        return()
    


