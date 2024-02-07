import os
import random
import sys

sys.path.insert(0, '..')
sys.path.insert(0, '../digital_death_trip_python/')

import nltk.corpus
from tools_for_general_use import *
from tools_for_trove import *
from tools_for_poetry_mashup import *

default_random_word_count = 3
default_search_word_count = 2
default_speed = 180
default_line_count = 12
default_max_words_per_line = 6

# comment out second line to keep Moby Dick as default corpus
corpus_text = 'melville-moby_dick.txt'
corpus_file_id = random.choice(nltk.corpus.gutenberg.fileids())
print(f"Corpus: {corpus_file_id}")
custom_corpus_words = set(w.lower() for w in nltk.corpus.gutenberg.words(corpus_file_id))
custom_corpus_words_sorted = sorted(custom_corpus_words)

try_say = test_say_something()
continue_script = True

# establish search word list: command line or random from corpus
if len(sys.argv) > 1:
    search_word_list = [word for word in sys.argv[1:]]
else:
    search_word_list = random.sample(custom_corpus_words_sorted, default_search_word_count)

current_quote_string = return_string_of_random_corpus_words(word_count=5, custom_corpus_words_sorted=custom_corpus_words_sorted)

# **** SETTING UP TROVE *** #
    
# check for Trove key
trove_key = return_trove_key()
if (trove_key == None):
    prompt_text = "\nNo Trove key found!\nEnter Trove key or 'N' to cancel script...\n"
    user_input = get_user_input(prompt_text=prompt_text)
    if (user_input[0].upper() == 'N'):
        continue_script = False
        sys.exit()
    else:
        trove_key = user_input.strip()
    
print(f"Search terms for Trove are: {search_word_list}\n")
search_word = ' '.join(search_word_list)
if (continue_script == True):
    trove_search_url = build_trove_search_url(trove_key=trove_key, search_word=search_word)
    trove_search_result = fetch_trove_search_result(trove_key=trove_key, trove_search_url=trove_search_url, also_print=False)
    if (trove_search_result == None):        
        continue_script = False
        say_something(f"\nSorry, no Trove results found for {search_word}")
    else:
        trove_search_result_metadata = parse_trove_result_metadata(trove_search_result=trove_search_result, search_word=search_word)
        result_count = trove_search_result_metadata["total"]
        print(f"\n{result_count} total result/s found for {search_word}")
        if (result_count == 0):
           continue_script = False
           print("cancelling...")
        else:
            trove_result_df = parse_trove_result_records_to_df(trove_search_result=trove_search_result, result_metadata=trove_search_result_metadata)
            summary_fields = []
            for field_name in ["year", "trove_article_heading", "heading", "date", "snippet", "id"]:
                if (field_name in trove_result_df):
                    summary_fields.append(field_name)
            print(trove_result_df[summary_fields])
            trove_result_list = list(trove_result_df["heading"])
            print(trove_result_list)


if (continue_script == False):
   sys.exit()


# *** NORMAL POEM COMPOSITION ***    

# 1. start up the meta source list with the external sources, if any
meta_source_list = ["trove", "random words from corpus"]

# 2. start talking to user
print("\n***")
greeting_string = "\nHello. I will assemble a poem for you."
say_something(text=greeting_string, try_say=try_say, speed=default_speed)

greeting_string = "I will use quotes from {}.".format(" and ".join(meta_source_list))
say_something(text=greeting_string, try_say=try_say, speed=default_speed)

greeting_string = f"I have searched Trove with the following word/s: {search_word}"
say_something(text=greeting_string, try_say=try_say, speed=default_speed)

greeting_string = f"My corpus of random words is {corpus_file_id}"
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
  greeting_string = "\nThank you. Please wait..."
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
    elif (meta_source_choice == "random words from corpus"):
      word_count = random.randint(1, default_random_word_count)
      current_quote_string = return_string_of_random_corpus_words(word_count=word_count, custom_corpus_words_sorted=custom_corpus_words_sorted)
      current_quote_metadata = "{} random words from {}".format(word_count, corpus_file_id)
      current_quote = [current_quote_string, current_quote_metadata]
    elif (meta_source_choice == "trove"):
       current_quote = [random.choice(trove_result_list), f"Trove search for {search_word}"]

    print(current_quote)
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