from tools_for_poetry_mashup import *
import random
import os
import sys
import string

default_speed = 180
default_line_count = 25
default_max_words_per_line = 8
ceiling_max_words_per_line = 50
default_random_word_count = 3

try_say = test_say_something()
print(try_say)

# 1. start up the meta source list with the external sources, if any
meta_source_list = ["the bible", "random words"]

book_list = return_bible_book_list()

# 2. start talking to user
print("\n***")
greeting_string = "\nHello. I will assemble a poem for you."
say_something(text=greeting_string, try_say=try_say, speed=default_speed)

greeting_string = "I will use quotes from {}.".format(" and ".join(meta_source_list))
say_something(text=greeting_string, try_say=try_say, speed=default_speed)

# 3. get line count
greeting_string = "\nHow many lines would you like in your poem?"
say_something(text=greeting_string, try_say=try_say, speed=default_speed)
line_count_input = get_user_input(prompt_text = "(default {})\n".format(default_line_count))
line_count = int(line_count_input or default_line_count)
max_tries = line_count * 3

# 4. get maximum length
greeting_string = "\nWhat is the maximum number of words you would like per line?"
say_something(text=greeting_string, try_say=try_say, speed=default_speed)
max_words_input = get_user_input(prompt_text = "(default {})\n".format(default_max_words_per_line))
if (max_words_input.isnumeric()):
  max_words_per_line = int(max_words_input)
else:
  max_words_per_line = default_max_words_per_line

#print("\nLine count choice: {0}, Max words per line: {1}".format(line_count, max_words_per_line))

# 4. initialise empty list for quotes
random_poetry_quotes = []

# 5. assemble random poem to hopefully collect the requisite number of lines: for each, random source choice, then random line choice
if (line_count > 0):
  greeting_string = "\nThank you. Please wait while I ask the internet."
  say_something(text=greeting_string, try_say=try_say, speed=default_speed)
  
  i = 0
  j = 0
  while ((i < line_count) and (j < max_tries)):
    j += 1  
    print("\nCollecting quote {}".format(i+1))
    current_quote = False
    meta_source_choice = random.choice(meta_source_list)
    print("choice: " + meta_source_choice)
    if (meta_source_choice == "the bible"):
      current_quote = return_random_bible(book_list=book_list)
    elif (meta_source_choice == "the online poetry database"):
      current_quote = return_random_poetry(author_list=[])
    elif (meta_source_choice == "random words"):
      word_count = random.randint(1, default_random_word_count)
      current_quote_string = return_string_of_random_words(word_count=word_count)
      current_quote_metadata = "{} random words from Python NLTK corpus".format(word_count)
      current_quote = [current_quote_string, current_quote_metadata]

    if (current_quote != False):      
      if (max_words_per_line != None):
        current_quote_stripped = current_quote[0].translate(str.maketrans('', '', string.punctuation))
        current_quote_split = word_tokenize(current_quote_stripped)
        if (len(current_quote_split) > max_words_per_line):
          current_quote[0] = ' '.join(current_quote_split[:max_words_per_line])
      random_poetry_quotes.append(current_quote)
      i += 1
  
  print("\n")


  greeting_string = "Thank you. I have finished composing the poem. Would you like to hear it?"
  say_something(text=greeting_string, try_say=try_say, speed=default_speed)

  poem_answer = (get_user_input(prompt_text = "(default yes)\n") or "yes")

  if (poem_answer[0].lower() != 'y'):
    greeting_string = "\nFine. Whatever.\n"
    say_something(text=greeting_string, try_say=try_say, speed=default_speed)
    sys.exit()

  print("\n\nI USED THE FOLLOWING SOURCES:")
  count = 0
  for quote in random_poetry_quotes:
    count += 1
    metadata_string = "{}-{}".format(count, quote[1])
    print(metadata_string)

  print("\n***")
  greeting_string = "\n\nHERE IS MY POEM"
  say_something(text=greeting_string, try_say=try_say, speed=default_speed)
  for quote in random_poetry_quotes:
    output_quote = remove_nuisance_characters_from_string(quote[0]).strip()
    output_quote = remove_stop_words_from_end_of_string(output_quote)
    #output_quote = output_quote.capitalize()
    if (output_quote != False):
      print(output_quote)
      say_something(text=output_quote, try_say=try_say, speed=default_speed, also_print=False)

  print("\n")