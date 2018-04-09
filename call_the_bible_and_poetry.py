import tools_for_talking
import random
import os

meta_source_list = ["the bible", "the online poetry database"]
default_directory = os.path.dirname(os.path.abspath(__file__))
line_count = 0

text_file_name = default_directory + os.path.normpath("/") + "taylor_project_lyrics_sample.txt"
text_file_quotes = tools_for_talking.read_text_file_to_array(text_file_name)
if text_file_quotes != False:
  text_file_quotes = tools_for_talking.remove_item_from_list(text_file_quotes, '')
  if len(text_file_quotes) > 0:
    meta_source_list.append(os.path.basename(text_file_name))

greeting_string = "Hello. I will assemble a poem, using a random mix of quotes."
tools_for_talking.say_something(text=greeting_string, speed=200)

exclude_list = []
for meta_source in meta_source_list:
  greeting_string = "Would you like me to search in: " + meta_source + "?"
  tools_for_talking.say_something(text=greeting_string, speed=200)
  user_choice = raw_input(greeting_string+" [y/n, default y]?") or "y"
  if user_choice != "y":
    exclude_list.append(meta_source)

for meta_source in exclude_list:
  meta_source_list.remove(meta_source)

if (len(meta_source_list) > 0):
  greeting_string = "Ok. I will search in: "
  for meta_source in meta_source_list:
    greeting_string += meta_source + " and "
  greeting_string = greeting_string[:-len(" and ")]
  tools_for_talking.say_something(text=greeting_string, speed=200)

  greeting_string = "How many quotes would you like me to collect?"
  tools_for_talking.say_something(text=greeting_string, speed=200, also_print=False)
  line_count = int(raw_input(greeting_string+" [default 4] ") or "4")
else:
  greeting_string = "No sources selected, cannot continue."
  tools_for_talking.say_something(greeting_string)

random_poetry_quotes = []

if (line_count > 0):
  greeting_string = "Thank you. Please wait while I collect {} random quotes for the poem.\n".format(line_count)
  tools_for_talking.say_something(text=greeting_string, speed=200)
  for i in range(1, line_count+1):
    print("\nCollecting quote {}".format(i))
    print("Choosing from: {}".format(meta_source_list))
    meta_source_choice = random.choice(meta_source_list)
    print("choice: " + meta_source_choice)     
    if (meta_source_choice == "the bible"):
      current_quote = tools_for_talking.return_random_bible(max_chapters=30)
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
  tools_for_talking.say_something(text=greeting_string, speed=200)
  
  print("I used the following texts:")
  metadata_list = []
  for quote in random_poetry_quotes:
    if quote[1] not in metadata_list:
      print(quote[1])
      metadata_list.append(quote[1])

  print("\n")  
  greeting_string = "HERE IS MY POEM"
  tools_for_talking.say_something(text=greeting_string, speed=200)
  for quote in random_poetry_quotes:
    final_quote = tools_for_talking.modify_string_for_email(quote[0])
    print(final_quote)
    tools_for_talking.say_something(text=final_quote, speed=150, also_print=False)

  print("\n")
  greeting_string = "End of poem. Thanks for listening."
  tools_for_talking.say_something(text=greeting_string, speed=200)