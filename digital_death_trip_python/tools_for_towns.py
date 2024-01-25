import csv
import random

from tools_for_general_use import *

def return_town_dictionary_from_single_file(file_name,
        directory_name='',
        town_file_type='ptv_stops',
        town_field_num=1,
        lat_field_num=None, long_field_num=None,
        filter_field_num=None, filter_field_value=None,
        include_row_summary=True):
    """
    Returns a dictionary of town names from a single file, can be of varying type
    """
    town_dictionary = {}
    try:
        file_path = os.path.join(directory_name, file_name)
        print(f"Attempting to make town dictionary from file {file_path}")
        with open(file_path, "r") as f:
            csv_data = list(csv.reader(f))[1:]
            for row in csv_data:
                include_current_town = True
                current_town_data = {}

                if (town_file_type == 'ptv_stops'):
                    current_town_name = extract_town_string_from_ptv_stop_string(row[town_field_num])
                elif (town_file_type == 'vicmap'):
                    print("HERE")
                    current_town_name = extract_town_string_from_vicmap_string(row[town_field_num])
                else:
                    current_town_name = row[town_field_num]

                if (filter_field_num != None):
                    if (row[filter_field_num] != filter_field_value):
                        include_current_town = False

                if (include_current_town != False):
                    current_town_data['lat'] = row[lat_field_num]
                    current_town_data['long'] = row[long_field_num]
                    if (include_row_summary == True):
                        current_town_data['source_row'] = str(row)
                    town_dictionary[current_town_name] = current_town_data

        return(town_dictionary)

    except:
        print(f"Encountered error in return_town_dictionary_from_single_file...")
        return(town_dictionary)


def return_town_dictionary_from_vicmap_file(town_data_directory='', vicmap_file_name='vic_and_border_locality_list.csv'):
    vicmap_town_dictionary = {}
    try:
        vicmap_town_dictionary = return_town_dictionary_from_single_file(file_name=vicmap_file_name,
            directory_name=town_data_directory,
            town_file_type='vicmap',
            town_field_num=3,
            lat_field_num = 11,
            long_field_num = 12,
            # filter_field_num = 6,
            # filter_field_value = 'VIC',
            include_row_summary = True)
        return(vicmap_town_dictionary)
    except:
        print("Error encountered in 'return_town_dictionary_from_vicmap_file'...")
        return(vicmap_town_dictionary)


def extract_town_string_from_vicmap_string(input_string):
    try:
        output_string = input_string.split("(")[0]
        output_string = output_string.title()
        return(output_string)
    except:
        return(input_string)
    

def return_ptv_stop_files(town_data_directory, file_pattern='*stops*'):
    stop_file_name_list = []
    try:
        stop_file_name_list = return_matching_file_names(input_path_name=town_data_directory, 
            file_extension = "txt", 
            file_pattern = file_pattern)
        return(stop_file_name_list)
    except:
        print(f"Encountered error in 'return_ptv_stop_files'")
        return(stop_file_name_list)


def return_town_dictionary_from_ptv_stop_files(stop_files):
    town_dictionary = {}
    try:
        for stop_file_name in stop_files:
            print(f"Current stop file: {stop_file_name}")
            current_town_dictionary = return_town_dictionary_from_single_file(file_name = stop_file_name, 
                town_file_type = 'ptv_stops', 
                town_field_num = 1, 
                lat_field_num = 2, 
                long_field_num = 3)
            print(len(current_town_dictionary))
            if (len(current_town_dictionary) > 0): 
                town_dictionary.update(current_town_dictionary)
            print(len(town_dictionary))
        return(town_dictionary)
    except:
        print("Error encountered in 'return_town_dictionary_from_ptv_stop_files'...")
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
        print(f"Encountered error in extract_town_string_from_gfts_stops_stop_string, input {input_string}, will skip...")
        return(result)


def print_town_dictionary(town_dictionary):
    try:
        for key, item in town_dictionary.items():
           print(item)
           # town? coordinates?
    except:
        return()
    


