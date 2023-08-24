from tools_for_poetry_mashup import *
import random
import os
import sys
import requests

default_speed = 170
default_line_count = 15

# 1. initalise source list
meta_source_list = ["the bible"]
book_list = return_bible_book_list()

# 2. announce intentions (but not speaking out loud)
greeting_string = "\nHello. I will choose {0} Bible verses for you.\nPlease wait while I ask the internet...\n".format(default_line_count)
say_something(text=greeting_string, speed=default_speed)

# 3. choose random bible verse, with maximum allowable tries
random_bible_quotes = []
i = 0
j = 0
max_tries = default_line_count * 3
while ((i < default_line_count) and (j < max_tries)):
  j += 1
  current_quote = return_random_bible(book_list=book_list, max_chapters=20, max_tries= max_tries)
  if (current_quote != False):   
    i += 1
    random_bible_quotes.append(current_quote)


# 4. say all quotes, but only print metadata
for quote in random_bible_quotes:
  print("\n")
  say_something(text=quote[0], speed=default_speed)
  print(quote[1])

if (len(random_bible_quotes) > 0):
  greeting_string = "\nThank you for listening.\nI trust you know what this means for you.\n"
  print(greeting_string)
else:
  greeting_string = "\nSorry. The Bible did not answer for you today.\nPlease be abetter person and then try again.\n"
  print(greeting_string)
