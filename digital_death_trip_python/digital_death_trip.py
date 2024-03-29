import os
import random
import sys
from pathlib import Path

sys.path.insert(0, '..')

from tools_for_general_use import *
from tools_for_trove import *
from tools_for_towns import *
from tools_for_language_processing import *

clear_screen()

# start variables: will default to tragedy unless command line argument passed
# IDEA: use random word generator
if len(sys.argv) > 1:
    search_word = sys.argv[1]
else:
    search_word = 'tragedy' 

if len(sys.argv) > 2:
    search_town = sys.argv[2]
else:
    search_town = None

# other start variables
default_speed = 180
max_articles_to_read = 3
max_calls = 10
try_say = test_say_something()
continue_script = True
trove_result_file_name = ''

# directory setup
script_directory = os.path.dirname(os.path.abspath(__file__))
parent_directory = return_parent_directory(script_directory)
operating_system = return_operating_system()
trove_key = return_trove_key()
default_output_path_name = os.path.join(script_directory, 'output_files')
os.makedirs(default_output_path_name, exist_ok=True)
default_town_directory = os.path.join(script_directory, 'town_lists')

# check for Trove key
if (trove_key == None):
    prompt_text = "\nNo Trove key found!\nEnter Trove key or 'N' to cancel script...\n"
    user_input = get_user_input(prompt_text=prompt_text)
    if (user_input[0].upper() == 'N'):
        continue_script = False
        sys.exit()
    else:
        trove_key = user_input.strip()
    
# start conversation        
say_something("\nHello, this is Digital Death Trip.", try_say=try_say, also_print=True, speed=default_speed)
say_something(f"Today I am talking to you from a {operating_system} operating system.", try_say=try_say, speed=default_speed)

# choice of town data: block only runs if no town name passed as command line
# TODO: move to function
if (search_town == None):
    say_something("\nWould you like to choose a town, or would you like me to make a random selection?", try_say=try_say, speed=default_speed)
    prompt_options = ['']
    prompt_options.append("Type 'r' or Enter for a random town choice (DEFAULT); OR")
    prompt_options.append("Type town name directly; OR")
    prompt_options.append("Type 'rf' for a random choice from existing output files; OR")
    prompt_options.append("Type 'exit' to cancel")
    prompt_text = "You can:" + "\n-\t".join(prompt_options) + "\n\n"
    user_input = get_user_input(prompt_text)

    # different options for assigning search town, depending on user choice
    if (user_input.upper() == 'EXIT'):
        continue_script = False
    elif ((len(user_input) == 0) or (user_input.upper() == 'R')):
        print("Random town")
        town_list = return_town_list_with_user_input(speed=default_speed,
            try_say=try_say, town_directory=default_town_directory)
        if (len(town_list) > 0):
            search_town = select_random_town_with_user_input(town_list=town_list, try_say=try_say, speed=default_speed)
        else:
            continue_script = False
    elif (user_input.upper() == 'RF'):
        print("\nSelecting random existing Trove file...")
        existing_trove_result_files = return_existing_trove_result_files(output_path_name=default_output_path_name)
        if (len(existing_trove_result_files) == 0):
            print("Sorry, no existing Trove files found")
            continue_script = False
        else:
            trove_result_file_name = random.choice(existing_trove_result_files)
            print(f"Selected file: {os.path.basename(trove_result_file_name)}")
            search_town = return_trove_file_search_town(trove_result_file_name)
            search_word = return_trove_file_search_word(trove_result_file_name)
            result_count = return_trove_file_result_count(trove_result_file_name)
            print(f"\n{result_count} result/s found on file for {search_town}")
            trove_result_df = pandas.read_csv(trove_result_file_name)
    else:
        search_town = user_input.strip().title()

if (continue_script == True):
    print("continuing...")
    print(f"Search town: {search_town}")
    print(f"Search word: {search_word}")

# start search (unless using existing file)
if (continue_script == True and trove_result_file_name == ''):
    say_something(f"Ok. I will now see if I can find any newspaper references to a {search_word} in {search_town}", try_say=try_say, speed=default_speed)
    # TODO: incorporate more file name error catching
    trove_search_url = build_trove_search_url(trove_key=trove_key, search_town=search_town, search_word=search_word)
    trove_search_result = fetch_trove_search_result(trove_key=trove_key, trove_search_url=trove_search_url)
    if (trove_search_result == None):        
        continue_script = False
        say_something(f"\nSorry, no {search_word} results found for {search_town}", try_say=try_say, speed=default_speed)
    else:
        trove_search_result_metadata = parse_trove_result_metadata(trove_search_result=trove_search_result, search_word=search_word, search_town=search_town)
        print(trove_search_result_metadata)
        result_count = trove_search_result_metadata["total"]
        print(f"\n{result_count} total result/s found for {search_town}")
        if (result_count == 0):
            continue_script = False
        else:
            say_something(f"\nI found {result_count} total results.", try_say=try_say, speed=default_speed)
            trove_result_df = parse_trove_result_records_to_df(trove_search_result=trove_search_result, result_metadata=trove_search_result_metadata)
            print(len(trove_result_df))
            print("Before filtering")
            trove_result_df = filter_trove_result_df(trove_result_df)
            print(len(trove_result_df))
            print("After filtering")
            trove_result_file_name = os.path.join(default_output_path_name, f"trove_result_{search_town}_{search_word}.csv")
            print(trove_result_file_name)
            # TODO: give option to create multiple calls or not
            print(f"Writing to {trove_result_file_name}")
            trove_result_df.to_csv(trove_result_file_name, index=False)
            next_url = return_next_url_from_trove_result_metadata(trove_result_metadata=trove_search_result_metadata)
            call_count = 0
            while (next_url != None and call_count < max_calls):
                call_count += 1
                # TODO: move key repeated steps to function
                trove_search_url = next_url
                trove_search_result = fetch_trove_search_result(trove_key=trove_key, trove_search_url=trove_search_url)
                trove_search_result_metadata = parse_trove_result_metadata(trove_search_result=trove_search_result, search_word=search_word, search_town=search_town)
                trove_result_df = parse_trove_result_records_to_df(trove_search_result=trove_search_result, result_metadata=trove_search_result_metadata)
                print(f"Total results from search {search_town} {search_word}: {result_count}")
                print(f"API call number {call_count} of maximum {max_calls}")
                print(len(trove_result_df))
                print("Before filtering")
                trove_result_df = filter_trove_result_df(trove_result_df)
                print(len(trove_result_df))
                print("After filtering")
                print(f"Appending to {trove_result_file_name}")
                trove_result_df.to_csv(trove_result_file_name, mode='a', header=False, index=False)
                next_url = return_next_url_from_trove_result_metadata(trove_result_metadata=trove_search_result_metadata)
                print(f"\n{next_url}")
                # TODO: clear up the clutter above!!
        

# TODO: limit random files to those with matching search word?

# summarise results
if (continue_script == True):
    trove_result_df = pandas.read_csv(trove_result_file_name)
    trove_result_df = filter_trove_result_df(trove_result_df)
    available_result_count = return_trove_file_result_count(trove_result_file_name)
    # TODO: deal with possible zero or near-zero results after filtering
    summary_fields = []
    for field_name in ["year", "trove_article_heading", "heading", "snippet"]:
        if (field_name in trove_result_df):
            summary_fields.append(field_name)
    
    # NOTE: I think this summary is better than the random picker
    # TODO: refine the word summary function; read some random headlines
    print("\n**SUMMARY VIEW**\n")
    print(trove_result_df[summary_fields])

    word_list = return_word_list_from_df(df=trove_result_df, field_list=["heading", "snippet"])
    # print(word_list)
    word_summary_list = return_custom_word_summary_list(input_words_all=word_list)
    
    #print(word_summary_list)
    for summary in word_summary_list:
        say_something(summary, try_say=try_say, speed=default_speed)


if (continue_script == True): 
    say_something(f"\nShall I pick a random {search_word} from {search_town}?", try_say=try_say, speed=default_speed)
    say_something("Or let me know if you would like to pick a specific article.", try_say=try_say, speed=default_speed)  

article_number = None
while (continue_script == True and article_number == None):
    prompt_text = "\nI will default to a random selection."
    prompt_text += "\nPlease enter 'pick' if you would like to pick. \nEnter 'exit' to cancel.\n"
    user_input = get_user_input(prompt_text = prompt_text)
    if (user_input.upper() == 'EXIT'):
        continue_script = False
    elif (user_input.upper() == 'PICK'):
        say_something("\nWhich article are you interested in?", try_say=try_say, speed = default_speed)  
        user_input = get_user_input(prompt_text = "\Please enter article number\nEnter 'exit' to cancel.\n")   
        # TODO: decide on whether to use article number or row number
        if (user_input.upper() == 'EXIT'):
            continue_script = False
        else:
            article_number = int(user_input) 
            say_something("Ok. Let's see.", try_say=try_say, speed=default_speed)
            article = trove_result_df.loc[article_number]
            print(article[summary_fields])
    else:
        article_number = random.choice(trove_result_df.index)
        print(article_number)
        say_something(f"Ok. Let's see. Here is my random {search_word} from {search_town}.", try_say=try_say, speed=default_speed)
        article = trove_result_df.loc[article_number]
        #print(article[summary_fields])
        for field_name in ["year", "heading"]:
            # TODO: refine what to read out here, or read later
            say_something(field_name, try_say=try_say, speed=default_speed)
            say_something(article[field_name], try_say=try_say, speed=default_speed)

    if (continue_script == True and article_number != None):
        say_something("\nWould you like to continue with this article? Or would you like to choose another?", try_say=try_say, speed = default_speed)  
        prompt_text = "\nPlease enter 'n' if you would like to pick another article. \nEnter 'exit' to cancel."
        prompt_text += f"\nEnter any other key to continue with this article ({article_number}).\n"
        user_input = get_user_input(prompt_text = prompt_text)
        if (user_input.upper() == 'EXIT'):
            continue_script = False
        elif (user_input.upper() == 'N'):
            article_number = None


print("exited loop...")

if (continue_script == True and article_number != None):  
    prompt_text = "\nWould you like me to get a copy of the whole article for you?"
    say_something(prompt_text, try_say=try_say, speed=default_speed)
    prompt_text = "\nEnter 'exit' to cancel\nEnter 'y' to find out more about this article.\n"
    user_input = get_user_input(prompt_text=prompt_text)                  
    if (user_input.lower() == 'y'):
        trove_article_id = article["id"]
        article_json = fetch_trove_newspaper_article(trove_key=trove_key, trove_article_id=trove_article_id, also_print=False)
        # TODO: error handling for json request
        # TODO: neaten this section, written quickly
        file_description = "trove_article_"
        file_description += str(article["year"])
        file_description += str(trove_article_id) + "_"
        max_heading = 15
        file_description += str(article["heading"][:max_heading])
        pdf_file_name = os.path.join(default_output_path_name, f"{file_description}.pdf")
        json_file_name = os.path.join(default_output_path_name, f"{file_description}.json")
        # TODO: error handling for failure getting json
        with open(json_file_name, 'w') as f:
            json.dump(article_json, f)
        print(f"Full article content written to json file: {json_file_name}")
        # TODO: error handling for failure getting pdf
        pdf_url = article_json["pdf"][0]
        print(pdf_url)
        response = requests.get(pdf_url)
        with open(pdf_file_name, 'wb') as f:
            f.write(response.content)
        print(f"PDF written to: {pdf_file_name}")
        # TODO: add speaking reference to files
        
        prompt_text = "Would you like me to read the full article?\n"
        say_something(prompt_text, try_say=try_say, speed=default_speed)
        prompt_text = "Enter 'y' to hear the full article.\nEnter any other key to skip this and just check output files.\n"
        user_input = get_user_input(prompt_text=prompt_text)                  
        if (user_input.lower() == 'y'):
            # TODO: decide on html approach and update dependencies if needed; e.g. requirements.txt
            article_html = article_json["articleText"]
            from bs4 import BeautifulSoup
            soup = BeautifulSoup(article_html)
            article_text = soup.get_text()
            say_something(article_text, try_say=try_say, speed=default_speed)

say_something("\nThank you, goodbye.", try_say=try_say, speed=default_speed)

# TODO: replicate some map summary potential here
