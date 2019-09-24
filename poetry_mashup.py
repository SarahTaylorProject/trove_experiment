import tools_for_talking
import random
import os
import codecs
import sys
import time

default_speed = 180
use_say_something = False
unique_input_lines = True
unique_output_lines = True

# 1. start up the meta source list with the external sources, if any
# could potentially make this interactive again
meta_source_list = ["the bible", "the online poetry database"]
book_list = ["genesis", "deuteronomy", "1corinthians", "2corinthians", "matthew", "mark", "luke", "john", "revelation"]
#meta_source_list = []
print("Meta source list: {}".format(meta_source_list))

# 2. look for local directory, create if needed
local_input_directory_name = os.path.dirname(os.path.abspath(__file__)) + os.path.normpath("/") + "poetry_input_files_current" + os.path.normpath("/")
print("Searching for local input files in: {}".format(local_input_directory_name))
if not os.path.isdir(local_input_directory_name):
  print("No local input directory found, I will create one. \nPlease put your poetry input material here in future: {}".format(local_input_directory_name))
  os.makedirs(local_input_directory_name)

# 3. build a local input dictionary from all the files in the input directory
local_input_file_name_list = os.listdir(local_input_directory_name)
local_input_quote_dictionary = {}
local_input_quote_total = 0
if (len(local_input_file_name_list) > 0):
  print("Now preparing {} local input files into dictionary...".format(len(local_input_file_name_list)))
  for input_file_name in local_input_file_name_list:
    full_input_file_name = local_input_directory_name + os.path.normpath("/") + input_file_name
    input_file_quote_list = tools_for_talking.read_text_file_to_array(full_input_file_name)
    if (unique_input_lines == True):
      input_file_quote_set = set(input_file_quote_list)
      input_file_quote_list = list(input_file_quote_set)
    if input_file_quote_list != False:
      input_file_quote_list = tools_for_talking.remove_item_from_list(input_file_quote_list, '')
      if len(input_file_quote_list) > 0:
        meta_source_list.append(os.path.basename(input_file_name))
        local_input_quote_dictionary[input_file_name] = input_file_quote_list
      local_input_quote_total += len(input_file_quote_list)
  print("Finished. Size of local input quote dictionary: {}".format(local_input_quote_total))

# 4. create output directory, if needed, then output file with date stamp
output_directory_name = os.path.dirname(os.path.realpath(__file__)) + os.path.normpath("/") + "poetry_output_files" + os.path.normpath("/")
if not os.path.isdir(output_directory_name):
  os.makedirs(output_directory_name)
output_file_name = output_directory_name + "random_poem_output_" + time.strftime("%Y%m%d").replace("/", "") + ".txt"
output_file = codecs.open(output_file_name, "w", encoding='utf-8')

# 5. start talking to user
greeting_string = "Hello. I will assemble a poem, using a random mix of quotes."
output_file.write(greeting_string)

# 6. get line count from user input
line_count = 0
if (len(meta_source_list) > 0):
  print("I will search in: {}".format(meta_source_list))
  greeting_string = "Ok. How many quotes would you like me to collect?"
  print(greeting_string)
  output_file.write(greeting_string)
  if (use_say_something == True):
    tools_for_talking.say_something(text=greeting_string, speed=default_speed, also_print=False)
  line_count = int((tools_for_talking.get_user_input(prompt_text = " [default 6] ") or 6))
else:
  greeting_string = "No sources selected, cannot continue."
  print(greeting_string)
  if (use_say_something == True):
    tools_for_talking.say_something(greeting_string)

# 7. assemble random poem: random source choice, then random line choice
random_poetry_quotes = []
if (line_count > 0):
  greeting_string = "Thank you. Please wait while I collect {} random quotes for the poem.\n".format(line_count)
  print(greeting_string)
  if (use_say_something == True):
    tools_for_talking.say_something(text=greeting_string, speed=default_speed)
  i = 0
  j = 0
  max_tries = line_count * 3
  while ((i < line_count) and (j < max_tries)):
    j += 1  
    print("\nCollecting quote {}".format(i))
    print("Choosing from: {}".format(meta_source_list))
    meta_source_choice = random.choice(meta_source_list)
    print("choice: " + meta_source_choice)
    if (meta_source_choice == "the bible"):
      current_quote = tools_for_talking.return_random_bible(book_list=book_list, max_chapters=20, max_tries=20)
    elif (meta_source_choice == "the online poetry database"):
      current_quote = tools_for_talking.return_random_poetry(full_metadata=False)
    else:
      current_line = random.choice(local_input_quote_dictionary[meta_source_choice])
      current_metadata = meta_source_choice
      current_quote = [current_line, current_metadata]

    if (current_quote != False):
      current_quote[0] = current_quote[0].replace(":", "\n")
      current_quote[0] = current_quote[0].replace(".", "\n")
      current_quote[0] = current_quote[0].replace(",", "\n")
      current_quote[0] = current_quote[0].replace(";", "\n")
      if ((unique_output_lines == False) or (current_quote not in random_poetry_quotes)):
        random_poetry_quotes.append(current_quote)
        i = i + 1
      else:
        print("skipping, repeat line: {0}".format(current_quote))

  print("\n")
  greeting_string = "Finished collecting {} random quotes.".format(line_count)
  print(greeting_string)
  if (use_say_something == True):
    tools_for_talking.say_something(text=greeting_string, speed=default_speed)

  greeting_string = "I used the following sources:"
  print(greeting_string)
  output_file.write("\n\n" + greeting_string)

  count = 0
  for quote in random_poetry_quotes:
    count += 1
    metadata_string = "{}-{}".format(count, quote[1])
    print(metadata_string)
    output_file.write("\n" + metadata_string)

  print("\n")
  greeting_string = "HERE IS MY POEM"
  print(greeting_string)
  output_file.write("\n\n" + greeting_string)
  if (use_say_something == True):
    tools_for_talking.say_something(text=greeting_string, speed=default_speed)
  for quote in random_poetry_quotes:
    final_quote = tools_for_talking.modify_string_for_email_header(quote[0]).strip()
    if (final_quote != False):
      print(final_quote)
      output_file.write("\n" + final_quote)
      if (use_say_something == True):
        tools_for_talking.say_something(text=final_quote, speed=default_speed, also_print=False)


  print("\n")
  greeting_string = "End of poem. Thanks for listening."
  tools_for_talking.say_something(text=greeting_string, speed=default_speed)
  output_file.write("\n\n" + greeting_string)