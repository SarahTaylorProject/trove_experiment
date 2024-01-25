import os
import random
import sys
from pathlib import Path

sys.path.insert(0, '..')

from tools_for_general_use import *
from tools_for_trove import *
from tools_for_towns import *
# from tools_for_geojson import *

clear_screen()

# options
search_word = 'tragedy'
default_speed = 180
allow_existing_files = True
max_articles_to_read = 3
try_say = test_say_something()

# directory setup
script_directory = os.path.dirname(os.path.abspath(__file__))
parent_directory = return_parent_directory(script_directory)
operating_system = return_operating_system()
trove_key = return_trove_key()

default_output_path_name = os.path.join(script_directory, 'output_files')
os.makedirs(default_output_path_name, exist_ok=True)

default_town_path_name = os.path.join(script_directory, 'town_lists')

print("Hello")

continue_script = True
trove_result_file_name = ''

existing_trove_file_list = return_existing_trove_file_list(output_path_name=default_output_path_name)
print(f"\nTrove result files already available: {len(existing_trove_file_list)}")
print_existing_trove_file_list(existing_trove_file_list)

say_something("\nHello, this is Digital Death Trip.", try_say=try_say, also_print=True, speed=default_speed)
say_something(f"Today I am talking to you from a {operating_system} operating system.", try_say=try_say, speed=default_speed)

say_something("\nWould you like to choose a town, or would you like me to make a random selection?", try_say=try_say, speed=default_speed)
prompt_options = ['']
prompt_options.append("Type 'r' for a random town choice (DEFAULT); OR")
prompt_options.append("Type town name directly; OR")
prompt_options.append("Type 'rf' for a random choice from existing output files; OR")
prompt_options.append("Type 'exit' to cancel")
prompt_text = "You can:" + "\n-\t".join(prompt_options) + "\n\n"

user_input = get_user_input(prompt_text)
print(f"Your choice: {user_input}\n")
print(len(user_input))

if (user_input.upper() == 'EXIT'):
    continue_script = False
elif ((len(user_input) == 0) or (user_input.upper() == 'R')):
    print("RANDOM TOWN")
    search_town = "to do!"
    stop_file_name_list = return_existing_stop_file_name_list(town_path_name=default_town_path_name)
    town_list = return_town_dictionary_from_stop_file_name_list(stop_file_name_list=stop_file_name_list)
    print(town_list)
#    search_town = select_random_town_with_user_input(default_speed = default_speed, town_path_name = default_town_path_name)
elif (user_input.upper() == 'RF'):
    print("\nSelecting random existing Trove file...")
    existing_trove_file_list = return_existing_trove_file_list(output_path_name=default_output_path_name)
    if (len(existing_trove_file_list) == 0):
        print("Sorry, no existing Trove files found")
        continue_script = False
    else:
        trove_result_file_name = random.choice(existing_trove_file_list)
        print(f"Selected file: {os.path.basename(trove_result_file_name)}")
        search_town = return_trove_file_search_town(trove_result_file_name)
        search_word = return_trove_file_search_word(trove_result_file_name)
else:
    search_town = user_input

print(f"Search town: {search_town}")
print(f"Search word: {search_word}")

if (continue_script == True):
    if (allow_existing_files == True):
        trove_result_file_name = search_for_matching_trove_file(existing_trove_file_list = existing_trove_file_list, search_town = search_town)
        if (trove_result_file_name != ''):
            print("Matching file found already on list, will use this one and be frugal:")
            print(f"{os.path.basename(trove_result_file_name)}")

# if (continue_script == true and trove_result_file_name == '') then
#    say_something("Ok. I will now see if I can find any newspaper references to a #{search_word} in #{search_town}")
#    trove_result_file_name = File.join(default_output_path_name, "trove_result_#{search_town}_#{search_word}.csv".gsub(/\s/,"_"))
#    trove_api_results = fetch_trove_search_results(search_town, search_word, my_trove_key)
#    puts("\nWriting results to file now...")
#    result_count = write_trove_search_results(trove_api_results, trove_result_file_name, search_word, search_town)
#    puts(result_count)

#    if (result_count == 0) then
#       continue_script = false
#       say_something("\nSorry, no #{search_word} results found for #{search_town}")
#    end
# end

# if (continue_script == true) then
#    result_count = count_trove_search_results_from_csv(trove_result_file_name)
#    random_article_range = Array(1..result_count)
#    say_something("\nI now have #{result_count} results on file.\nWould you like me to read a few headlines, to get a sense of the #{search_word}s in #{search_town}?", also_print = true, speed = default_speed)
#    user_input = get_user_input(prompt_text = "Enter 'n' if not interested, \nEnter 'exit' to cancel entirely, \nEnter any other key to hear a few sample headlines...")
#    if (user_input.upcase == 'EXIT') then
#       continue_script = false
#    elsif (user_input.upcase == 'ALL') then
#       read_trove_headlines(input_trove_file = trove_result_file_name, speed = default_speed)
#    elsif (user_input.upcase != 'N') then
#       # reads random sample of 5
#       random_article_numbers = Array.new(4) { rand(1..result_count) }
#       random_article_numbers = random_article_numbers.uniq
#       read_trove_headlines(input_trove_file = trove_result_file_name, speed = default_speed, article_numbers = random_article_numbers)
#    end
# end

# if (continue_script == true) then 
#    say_something("\nShall I pick a random #{search_word} from this place?", also_print = true, speed = default_speed)
#    say_something("Or let me know if you would like to pick a specific article.", also_print = true, speed = default_speed)  
# end

# while (continue_script == true) do      
#    user_input = get_user_input(prompt_text = "\nI will default to a random selection. \nPlease enter 'pick' if you would like to pick. \nEnter 'exit' to cancel.")
#    if (user_input.upcase == 'EXIT') then
#       continue_script = false
#    elsif (user_input.upcase == 'PICK') then 
#       say_something("\nWhich article are you interested in?", also_print = true, speed = default_speed)  
#       user_input = get_user_input(prompt_text = "\Please enter article number\nEnter 'exit' to cancel")   
#       if (user_input.upcase == 'EXIT') then
#          continue_script = false
#       else
#          article_numbers = return_int_array_from_string(user_input, divider = ",")   
#          if (article_numbers == false) then
#             continue_script = false
#          else
#             say_something("Ok. Let's see.", also_print = true, speed = default_speed)
#             article_number = article_numbers[0]
#          end
#       end
#    else
#       article_number = random_article_range.sample
#       say_something("Ok. Let's see. Here is my random #{search_word} from #{search_town}.", also_print = true, speed = default_speed)
#       puts(article_number)
#    end
#    if (continue_script == true) then  
#       puts(article_number)
#       read_trove_results_by_array(input_trove_file = trove_result_file_name, article_numbers = [article_number], speed = default_speed)
#       say_something("\n.....")
#       say_something("So, that was one #{search_word} from #{search_town}", also_print = true, speed = default_speed)   
#       say_something("\nWould you like me to get a copy of the whole article for you?", also_print = true, speed = default_speed)                  
#       user_input = get_user_input(prompt_text = "\nEnter 'n' for a different #{search_word}\nEnter 'exit' to cancel\nEnter 'y' to find out more")
#       if (user_input.upcase == 'Y') then
#          trove_article_id = return_record_from_csv_file(input_file = trove_result_file_name, row_number = article_number, column_number = 9)
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

# puts("\nWill update map files before exiting...")
# current_result = write_geojson_for_all_csv_files(town_path_name = default_town_path_name, output_path_name = default_output_path_name)
# if (current_result != false) then
#    puts("\nHave written #{current_result} map objects to your output directory.")
#    puts("\nYou may find the map files useful.\nYou can open them in QGIS or in Google Maps.")
# else
#    puts("\nSorry, encountered error with updating map files.")
# end
