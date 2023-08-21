from tools_for_poetry_mashup import *
import random
import os
import sys
import requests

espeak_executable_path = 'C:\Elevate\eSpeak NG\espeak-ng.exe'
default_speed = 170
default_line_count = 1

# 1. initalise source list
meta_source_list = ["the bible"]
book_list = return_bible_book_list()

# 2. start talking to user
greeting_string = "\nHello. I will choose a Bible verse for you.\nPlease wait while I ask the internet...\n"
say_something(text=greeting_string, speed=default_speed, espeak_executable_path=espeak_executable_path)

# 3. choose random bible verse, with maximum allowable tries
random_bible_quotes = []
j = 0
max_tries = default_line_count * 3
current_quote = return_random_bible(book_list=book_list, max_chapters=20, max_tries= max_tries)
if (current_quote != False):   
  random_bible_quotes.append(current_quote)

# 4. 
for quote in random_bible_quotes:
  #print(quote)
  say_something(text=quote[0], speed=default_speed, espeak_executable_path=espeak_executable_path)
  say_something(text=quote[1], speed=default_speed, espeak_executable_path=espeak_executable_path)

if (len(random_bible_quotes) > 0):
  greeting_string = "\nThank you for listening.\nI trust you know what this means for you.\n"
  say_something(text=greeting_string, speed=default_speed, espeak_executable_path=espeak_executable_path)
else:
  greeting_string = "\nSorry. The Bible did not answer for you today.\nPlease be abetter person and then try again.\n"
  say_something(text=greeting_string, speed=default_speed, espeak_executable_path=espeak_executable_path)
