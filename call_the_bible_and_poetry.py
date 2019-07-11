import tools_for_talking
import random
import os
import codecs
import sys

default_speed = 180
meta_source_list = ["the bible", "the online poetry database"]
default_directory = os.path.dirname(os.path.abspath(__file__))
line_count = 0
output_file = codecs.open("random_poem_output.txt", "w", encoding='utf-8')

text_file_name = default_directory + os.path.normpath("/") + "funny_lyrics_sample.txt"
text_file_quotes = tools_for_talking.read_text_file_to_array(text_file_name)
if text_file_quotes != False:
  text_file_quotes = tools_for_talking.remove_item_from_list(text_file_quotes, '')
  if len(text_file_quotes) > 0:
    meta_source_list.append(os.path.basename(text_file_name))

greeting_string = "Hello. I will assemble a poem, using a random mix of quotes."
output_file.write(greeting_string)
tools_for_talking.say_something(text=greeting_string, speed=default_speed)

exclude_list = []
for meta_source in meta_source_list:
  greeting_string = "Would you like me to search in: " + meta_source + "?"
  tools_for_talking.say_something(text=greeting_string, speed=default_speed)
  user_choice = (tools_for_talking.get_user_input(prompt_text = " [y/n, default y]?") or "y" )  
  if user_choice != "y":
    exclude_list.append(meta_source)
  if user_choice == False:
    break

for meta_source in exclude_list:
  meta_source_list.remove(meta_source)

if (len(meta_source_list) > 0):
  print("I will search in: {}".format(meta_source_list))
  greeting_string = "Ok. How many quotes would you like me to collect?"
  tools_for_talking.say_something(text=greeting_string, speed=default_speed, also_print=False)
  line_count = int((tools_for_talking.get_user_input(prompt_text = " [default 6] ") or 6))
else:
  greeting_string = "No sources selected, cannot continue."
  tools_for_talking.say_something(greeting_string)

# note April 27th: need separate error handler for no sources selected, and for NON INTEGER input

random_poetry_quotes = []

if (line_count > 0):
  greeting_string = "Thank you. Please wait while I collect {} random quotes for the poem.\n".format(line_count)
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
      current_line = random.choice(text_file_quotes)
      print(current_line)
      current_metadata = meta_source_choice
      current_quote = [current_line, current_metadata]

    if (current_quote != False):
      random_poetry_quotes.append(current_quote)

  print("\n")
  greeting_string = "Finished collecting {} random quotes.".format(line_count)
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
  output_file.write("\n\n" + greeting_string)
  tools_for_talking.say_something(text=greeting_string, speed=default_speed)
  for quote in random_poetry_quotes:
    final_quote = tools_for_talking.modify_string_for_email_header(quote[0]).strip()
    if (final_quote != False):
      print(final_quote)
      tools_for_talking.say_something(text=final_quote, speed=default_speed, also_print=False)
      output_file.write("\n" + final_quote)

  print("\n")
  greeting_string = "End of poem. Thanks for listening."
  tools_for_talking.say_something(text=greeting_string, speed=default_speed)
  output_file.write("\n\n" + greeting_string)