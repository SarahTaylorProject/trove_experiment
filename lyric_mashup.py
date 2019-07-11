import tools_for_talking
import random
import os
import codecs
import sys

default_speed = 180
use_say_something = False
meta_source_list = ["the bible", "the online poetry database"]
meta_source_list = ["the online poetry database"]
#meta_source_list = []
meta_source_list = []

default_directory = os.path.dirname(os.path.abspath(__file__))
line_count = 0
output_file = codecs.open("random_poem_output.txt", "w", encoding='utf-8')
text_file_quote_dictionary = {}

text_file_name_list = ["flowers_by_the_roadside.txt", "old_town_road.txt", "nobody_knows_what_the_neighbours_know.txt", "taylor_project_lyrics_sample.txt"]
text_file_name_list = ["taylor_project_lyrics_sample.txt", "early_warning_signs.txt", "focus_areas.txt"]
text_file_name_list = ["horses.txt", "papa_was_a_rodeo.txt"]
text_file_name_list = ["in_the_end.txt", "focus_areas.txt", "bharath.txt"]
text_file_name_list = ["in_the_end.txt", "bharath.txt", "focus_areas.txt", "taylor_project_lyrics_sample.txt"]
#text_file_name_list = ["early_warning_signs.txt"]

for text_file_name in text_file_name_list:
  full_text_file_name = default_directory + os.path.normpath("/") + text_file_name
  text_file_quotes = tools_for_talking.read_text_file_to_array(full_text_file_name)
  if text_file_quotes != False:
    text_file_quotes = tools_for_talking.remove_item_from_list(text_file_quotes, '')
    if len(text_file_quotes) > 0:
      meta_source_list.append(os.path.basename(text_file_name))
      text_file_quote_dictionary[text_file_name] = text_file_quotes

print(meta_source_list)
#for text_file_name in text_file_name_list:
#  print(text_file_quote_dictionary[text_file_name])

greeting_string = "Hello. I will assemble a poem, using a random mix of quotes."
output_file.write(greeting_string)

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

random_poetry_quotes = []

if (line_count > 0):
  greeting_string = "Thank you. Please wait while I collect {} random quotes for the poem.\n".format(line_count)
  print(greeting_string)
  if (use_say_something == True):
    tools_for_talking.say_something(text=greeting_string, speed=default_speed)
  for i in range(1, line_count+1):
    print("\nCollecting quote {}".format(i))
    print("Choosing from: {}".format(meta_source_list))
    meta_source_choice = random.choice(meta_source_list)
    print("choice: " + meta_source_choice)
    if (meta_source_choice == "the bible"):
      current_quote = tools_for_talking.return_random_bible(max_chapters=20, max_tries=20)
    elif (meta_source_choice == "the online poetry database"):
      current_quote = tools_for_talking.return_random_poetry(full_metadata=False)
    else:
      current_line = random.choice(text_file_quote_dictionary[meta_source_choice])
      print(current_line)
      current_metadata = meta_source_choice
      current_quote = [current_line, current_metadata]

    if (current_quote != False):
      random_poetry_quotes.append(current_quote)

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