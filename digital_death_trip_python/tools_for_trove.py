import json
import os
import pandas
import requests
from tools_for_general_use import *

def return_trove_key(trove_key_file="my_trove.txt", trove_key_directory="keys"):
    # Looks in various likely locations for Trove key file
    # Returns None if unsuccessful, returns key if successful
    # TODO: move and modify for general use file
    try:
        trove_key = None
        script_directory = return_script_directory()
        parent_directory = return_parent_directory(script_directory)

        try_directory = os.path.join(script_directory, trove_key_directory)
        try_file_path = os.path.join(try_directory, trove_key_file)
        trove_key = try_read_trove_key_file(try_file_path)
        
        if (trove_key == None):
            try_directory = os.path.join(parent_directory, trove_key_directory)
            try_file_path = os.path.join(try_directory, trove_key_file)
            trove_key = try_read_trove_key_file(try_file_path)
        if (trove_key == None):
            try_directory = trove_key_directory
            try_file_path = os.path.join(try_directory, trove_key_file)
            trove_key = try_read_trove_key_file(try_file_path)
        if (trove_key == None):
            try_directory = ''
            try_file_path = os.path.join(try_directory, trove_key_file)
            trove_key = try_read_trove_key_file(try_file_path)

        return(trove_key)
    except:
        print(f"Error with finding Trove key {trove_key_file} in {trove_key_directory}")
        return(None)


def try_read_trove_key_file(trove_key_file_path="my_trove.txt"):
    trove_key = None
    try:
        with open(trove_key_file_path, 'r') as f:
            trove_key = f.readline()
            print(f"Found Trove key")
        return(trove_key)
    except:
        return(trove_key)
    

def return_existing_trove_result_files(output_path_name, 
                                       also_print=False, 
                                       file_pattern="trove_result*"):
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
            result_count = return_trove_file_result_count(file_name)
            print(f"{os.path.basename(file_name)}: {search_town} {search_word} ({result_count} records)")
    except:
        return()


def return_trove_file_search_town(input_trove_file, search_town_field="search_town"):
    """
    Returns the town name for a Trove CSV file, by using the first row 
    This is marginally easier than inferring the search town from the file name
    If errors encountered, returns blank string
    If successful, returns the search town name from the Trove search result CSV file (defaults to field 1)
    """
    search_town = ''
    try:
        trove_df = pandas.read_csv(input_trove_file)
        search_town = trove_df[search_town_field].iloc[0]
        return(search_town)
    except:
        print(f"Error encountered in 'return_trove_file_search_town', returning {search_town}...")
        return(search_town)


def return_trove_file_search_word(input_trove_file, search_word_field="search_word"):
    """
    Returns the search word for a Trove CSV file
    This is marginally easier than inferring the search word from the file name
    If errors encountered, returns blank string
    If successful, returns the search town name from the Trove search result CSV file
    """
    search_word = ''
    try:
        trove_df = pandas.read_csv(input_trove_file)
        search_word = trove_df[search_word_field].iloc[0]
        return(search_word)
    except:
        print(f"Error encountered in 'return_trove_file_search_word', returning {search_word}...")
        return(search_word)


def return_trove_file_result_count(input_trove_file):
    result = None
    try:
        trove_df = pandas.read_csv(input_trove_file)
        result = len(trove_df)
        return(result)
    except:
        print(f"Error encountered in 'return_trove_file_search_word', returning {search_word}...")
        return(result)


def search_for_matching_trove_file(existing_trove_result_files, 
                                   search_town, search_word='', 
                                   search_word_field=0, search_town_field=1):
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
                print(f"Matching town in: {current_file_name}")
                if (search_word != ''):
                    print(f"Will also check for search word {search_word}")
                    current_word = return_trove_file_search_word(input_trove_file=current_file_name, search_word_field=search_word_field)
                else:
                    current_word = search_word
            
            if (current_town.upper() == search_town.upper()):
                if (current_word.upper() == search_word.upper()):                
                    print(f"Matching file: {current_file_name}")
                return(current_file_name)
  
        return(matching_trove_file)
    except:
        print(f"Error encountered in 'search_for_matching_trove_file', returning empty list...")
        return(matching_trove_file)



def build_trove_search_url(trove_key='',
                                search_town='', search_word='',
                                separate_search_word_list=[],
                                trove_search_base="https://api.trove.nla.gov.au/v3/result?",
                                url_quote='%22', url_space='%20',
                                search_category='newspaper',
                                result_start='%2A', result_n=20,
                                result_sortby='relevance',
                                result_bulkharvest='false',
                                result_reclevel='brief',
                                result_encoding='json'):
    """
    Build URL for Trove search: suited to the Digital Death Trip town search
    """
    trove_search_url = None
    try:
        search_string_list = []
        for input_word in [search_town, search_word]:
            print("Here")
            if (input_word != ''):
                current_word = remove_nuisance_characters_from_string(input_word)
                current_word = url_quote + current_word.replace(' ', url_space) + url_quote
                if (len(current_word) > 0):
                    search_string_list.append(current_word)

        for input_word in separate_search_word_list:
            input_word = input_word.strip()
            current_word = remove_nuisance_characters_from_string(input_word)
            current_word = current_word.replace(' ', url_space)
            if (len(current_word) > 0):
                search_string_list.append(current_word)
        print(search_string_list)
        search_string = url_space.join(search_string_list)
        print(search_string)

        request_list = []
        request_list.append(f"key={trove_key}")
        request_list.append(f"q={search_string}")
        request_list.append(f"category={search_category}")
        request_list.append(f"n={result_n}")
        request_list.append(f"sortby={result_sortby}")
        request_list.append(f"bulkHarvest={result_bulkharvest}")
        request_list.append(f"reclevel={result_reclevel}")
        request_list.append(f"encoding={result_encoding}")
        request_list.append(f"s={result_start}")

        trove_search_string = "&".join(request_list)
        trove_search_url = trove_search_base + trove_search_string
        print(trove_search_url)
        return(trove_search_url)
    except:
        print("Error getting API results...")
        return(trove_search_url)

# TODO: make separate url function for just a list of words

def fetch_trove_search_result(trove_key='',
                              trove_search_url='',
                              also_print=True):
    trove_search_result = None
    try:
        if ('key=' not in trove_search_url):
            trove_search_url = trove_search_url + "&key=" + trove_key
        trove_search_full_result = trove_search_result = requests.get(trove_search_url)
        if (trove_search_full_result.status_code == 200):
            trove_search_result= json.loads(trove_search_full_result.content)
            if (also_print==True):
                print(trove_search_result)
        return(trove_search_result)    
    except:
        print("Error getting API results...")
        return(trove_search_result)


def parse_trove_result_metadata(trove_search_result,
                                search_word='', search_town='',
                                category_code='newspaper'):
    result_metadata = {}
    try:
        result_metadata["search_town"] = search_town
        result_metadata["search_word"] = search_word
        result_metadata["category_code"] = category_code

        # TODO: rewrite as a list
        result_metadata["total"] = None
        result_metadata["s"] = None
        result_metadata["n"] = None
        result_metadata["next"] = None

        category_list = trove_search_result["category"]
        for current_category in category_list:
            if current_category["code"] == category_code:
                current_category_records = current_category["records"]
                for key in result_metadata:
                    if key in current_category_records:
                        result_metadata[key] = current_category_records[key]
    
        return(result_metadata)
    except:
        print("Error parsing metadata...")
        return(result_metadata)


def return_next_url_from_trove_result_metadata(trove_result_metadata, next_field_name="next"):
    next_url = None
    # todo: fix naming conventions re: result, search, etc.
    try:
        if (next_field_name in trove_result_metadata):
            next_url = trove_result_metadata[next_field_name]
        # print(f"Next URL: {next_url}")
        return(next_url)
    except:
        print("Error getting API results...")
        return(next_url) 


def parse_trove_result_records_to_df(trove_search_result,
                                     result_metadata=None,
                                     category_code='newspaper',
                                     result_headings=["year", "heading", "snippet", "troveUrl", "id", "url", "date", "title", "page", "relevance"]):
    result_records = []
    try:
        category_list = trove_search_result["category"]
        for current_category in category_list:
            if current_category["code"] == category_code:
                current_category_articles = current_category["records"]["article"]
                for current_article in current_category_articles:
                    current_article_dict = dict.fromkeys(result_headings)
                    for key in result_headings:
                        if key in current_article:
                            current_article_dict[key] = current_article[key]
                    current_article_dict["year"] = current_article_dict["date"].split("-")[0]
                    if (result_metadata != None):
                        current_article_dict.update(result_metadata)
 
                    result_records.append(current_article_dict)
        # TODO: put individual article parsing in separate function to deal with potential duds
        result_df = pandas.DataFrame.from_dict(result_records)
        return(result_df)
    except:
        print("error in parse_trove_results_to_df")
        return(result_records)


def filter_trove_result_df(trove_result_df, 
        remove_advertising=True, 
        min_heading_length=5,
        min_snippet_length=15):
    try:

        if (("heading" in trove_result_df.columns) and (min_heading_length > 0)):
            print(f"removing records with headings less than {min_heading_length} characters")
            trove_result_df = trove_result_df[trove_result_df["heading"].str.len() >= min_heading_length]
            print(len(trove_result_df))

        if (("snippet" in trove_result_df.columns) and (min_snippet_length > 0)):
            print(f"removing records with snippets shorter than {min_snippet_length} characters")
            trove_result_df = trove_result_df[trove_result_df["snippet"].str.len() >= min_snippet_length]
            print(len(trove_result_df))

        if (("heading" in trove_result_df.columns) and (remove_advertising == True)):
            print("Removing advertising...")
            trove_result_df = trove_result_df[trove_result_df["heading"].str.contains("dvertising") == False]
            # TODO: make case insensitive
            print(len(trove_result_df))

        return(trove_result_df)
    except:
        print("Error in filter_trove_result_df")
        return(trove_result_df)




def fetch_trove_newspaper_article(trove_article_id,
                                trove_key,
                                trove_article_base="https://api.trove.nla.gov.au/v3/newspaper/",
                                result_reclevel='full',
                                result_include='articletext',
                                result_encoding='json',
                                also_print=False):
    """
    Fetches individual Trove article
    #e.g. https://api.trove.nla.gov.au/newspaper/45649893?reclevel=full&key=<insert key here>
    """
    trove_article = None
    try:
        print(f"Attempting to fetch newspaper article {trove_article_id}")
        request_list = []
        request_list.append(f"key={trove_key}")
        request_list.append(f"reclevel={result_reclevel}")
        request_list.append(f"include={result_include}")
        request_list.append(f"encoding={result_encoding}")
        request_string = "&".join(request_list)
        trove_article_url = trove_article_base + str(trove_article_id) + '?' + request_string
        if (also_print):
            print(trove_article_url)
        trove_article_result = requests.get(trove_article_url)
        print(trove_article_result)
        if (trove_article_result.status_code == 200):
            trove_article = json.loads(trove_article_result.content)
            #trove_article = trove_article_result.content
            if (also_print):
                print(trove_article)
        return(trove_article)    

    except:
        print("Error getting article...")
        return(trove_article)



# TODO: get state for publication title https://api.trove.nla.gov.au/v2/newspaper/title/225?key=KEY
# use this to filter where state = VIC or state matches town