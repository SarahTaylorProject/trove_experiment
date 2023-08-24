from tools_for_poetry_mashup import *
import random
import os
import sys
import string

default_speed = 180
default_line_count = 1
default_max_words_per_line = 3
ceiling_max_words_per_line = 20

# 1. start up the meta source list with the external sources, if any
meta_source_list = ["random words"]

book_list = return_bible_book_list()

# 2. start talking to user
print("\n***")
greeting_string = "\nHello. I will assemble a random series of words for you."
say_something(text=greeting_string, speed=default_speed)

# 3. line count: always 1
line_count = default_line_count

# 4. get maximum word count
greeting_string = "\nWhat is the maximum number of words you would like?"
say_something(text=greeting_string, speed=default_speed)
max_words_input = get_user_input(prompt_text = "(default {})\n".format(default_max_words_per_line))
if (max_words_input.isnumeric()):
  max_words_per_line = int(max_words_input)
else:
  max_words_per_line = default_max_words_per_line

# 4. initialise empty list for quotes
random_poetry_quotes = []

greeting_string = "\nThank you. Please wait."
say_something(text=greeting_string, speed=default_speed)

# 5. just get a random series of words: no need for a loop, as it's a single quote  
word_count = random.randint(1, max_words_per_line)
current_quote_string = return_string_of_random_words(word_count=max_words_per_line)
current_quote_metadata = "{} random words from Python NLTK corpus".format(max_words_per_line)
current_quote = [current_quote_string, current_quote_metadata]
random_poetry_quotes.append(current_quote)

print("\n***")
greeting_string = "HERE IS YOUR RESULT:"
say_something(text=greeting_string, speed=default_speed)
for quote in random_poetry_quotes:
  output_quote = remove_nuisance_characters_from_string(quote[0]).strip()
  output_quote = remove_stop_words_from_end_of_string(output_quote)
  if (output_quote != False):
    print(output_quote)
    say_something(text=output_quote, speed=default_speed, also_print=False)


print("\n\nI USED THE FOLLOWING SOURCES:")
count = 0
for quote in random_poetry_quotes:
  count += 1
  metadata_string = "{}: {}".format(count, quote[1])
  print(metadata_string)

print("\n")