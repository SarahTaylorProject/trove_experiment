import os
import random
import sys
from pathlib import Path

sys.path.insert(0, '..')

from tools_for_general_use import *
from tools_for_trove import *
from tools_for_towns import *

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
        say_something(f"\nSorry, no {search_word} results found for {search_town}")
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
                print(f"Appending to {trove_result_file_name}")
                trove_result_df.to_csv(trove_result_file_name, mode='a', header=False, index=False)
                next_url = return_next_url_from_trove_result_metadata(trove_result_metadata=trove_search_result_metadata)
                print(f"\n{next_url}")
        
# IDEA: summary of key words
# TODO: limit random files to those with matching search word?

# summarise results
if (continue_script == True):
    # TODO: neaten the work with result count: total results vs available result
    trove_result_df = pandas.read_csv(trove_result_file_name)
    available_result_count = return_trove_file_result_count(trove_result_file_name)
    summary_fields = []
    for field_name in ["year", "trove_article_heading", "heading", "date", "snippet"]:
        if (field_name in trove_result_df):
            summary_fields.append(field_name)
    
    # NOTE: I think this summary is better than the random picker; extend on this and summarise?
    print("\n**SUMMARY VIEW**\n")
    print(trove_result_df[summary_fields])

    say_something(f"\nI now have {result_count} results available on file.\nWould you like me to read a few headlines?", try_say=try_say, speed=default_speed)
    user_input = get_user_input(prompt_text="Enter 'n' if not interested\nEnter any other key to hear a few sample headlines...")
    if (user_input.upper() == 'EXIT'):
        continue_script = False
    elif (user_input.upper() != 'N'):
        # reads summaries of random sample
        sample_size = 10
        if (available_result_count < sample_size):
            sample_size = available_result_count
        random_row_numbers = random.sample(range(0, available_result_count), sample_size)

        random_row_numbers = list(set(random_row_numbers))
        read_trove_summary_fields(trove_result_df=trove_result_df, 
                                  try_say=try_say,
                                  speed=default_speed,
                                  summary_fields=["year", "heading"], 
                                  row_numbers=random_row_numbers)
   
if (continue_script == True): 
    say_something(f"\nShall I pick a random {search_word} from this place?", try_say=try_say, speed=default_speed)
    say_something("Or let me know if you would like to pick a specific article.", try_say=try_say, speed=default_speed)  
    #TODO: build this functionality; and decide on best option for using ID field

article_number = None
# TODO: fix loop condition
while (continue_script == True and article_number == None):      
    user_input = get_user_input(prompt_text = "\nI will default to a random selection. \nPlease enter 'pick' if you would like to pick. \nEnter 'exit' to cancel.")
    # TODO: update the user input format to list
    if (user_input.upper() == 'EXIT'):
        continue_script = False
    elif (user_input.upper() == 'PICK'):
        say_something("\nWhich article are you interested in?", try_say=try_say, speed = default_speed)  
        user_input = get_user_input(prompt_text = "\Please enter article number\nEnter 'exit' to cancel")   
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
        # TODO: reduce repetition with pick option
        article = trove_result_df.loc[article_number]
        print(article[summary_fields])
        # TODO: OPTION TO KEEP LOOPING! currently stops

#    if (continue_script == true) then  
#       puts(article_number)
#       read_trove_results_by_array(input_trove_file = trove_result_file_name, article_numbers = [article_number], speed = default_speed)
#       say_something("\n.....")
#       say_something("So, that was one #{search_word} from #{search_town}", also_print = true, speed = default_speed)   
#       say_something("\nWould you like me to get a copy of the whole article for you?", also_print = true, speed = default_speed)                  
#       user_input = get_user_input(prompt_text = "\nEnter 'n' for a different #{search_word}\nEnter 'exit' to cancel\nEnter 'y' to find out more")
#       if (user_input.upcase == 'Y') then
#          trove_article_id = return_record_from_single_file(input_file = trove_result_file_name, row_number = article_number, column_number = 9)
#          puts(trove_article_id)
#          trove_article_result = fetch_trove_newspaper_article(trove_article_id = trove_article_id, trove_key = my_trove_key)
#          trove_article_file = write_trove_newspaper_article_to_file(trove_article_result = trove_article_result, trove_article_id = trove_article_id, output_path_name = default_output_path_name)        
#          if (trove_article_file != false) then
#             puts("\nContent written to file: #{trove_article_file}")
#          end
#          say_something("Good luck!", also_print = true, speed = default_speed)
#          continue_script = false
#       elsif (user_input.upcase == 'EXIT') then      
#          continue_script = false
#       end
#    end
# end

# say_something("\nThank you, goodbye.", also_print = true, speed = default_speed)

# TODO: replicate some map summary potential here
