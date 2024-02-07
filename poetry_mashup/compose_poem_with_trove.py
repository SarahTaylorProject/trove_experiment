import os
import random
import sys

sys.path.insert(0, '..')
sys.path.insert(0, '../digital_death_trip_python/')

import nltk.corpus
from tools_for_general_use import *
from tools_for_trove import *

default_random_word_count = 2

# comment out second line to keep Moby Dick as default corpus
corpus_text = 'melville-moby_dick.txt'
corpus_file_id = random.choice(nltk.corpus.gutenberg.fileids())
print(f"Corpus: {corpus_file_id}")
corpus_words = set(w.lower() for w in nltk.corpus.gutenberg.words(corpus_file_id))
corpus_words_sorted = sorted(corpus_words)

try_say = test_say_something()
continue_script = True

# establish search word list: command line or random from corpus
if len(sys.argv) > 1:
    search_word_list = [word for word in sys.argv[1:]]
else:
    search_word_list = random.sample(corpus_words_sorted, default_random_word_count)

# directory setup
# script_directory = os.path.dirname(os.path.abspath(__file__))
# parent_directory = return_parent_directory(script_directory)
# operating_system = return_operating_system()


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
        trove_result_df = parse_trove_result_records_to_df(trove_search_result=trove_search_result, result_metadata=trove_search_result_metadata)
        summary_fields = []
        for field_name in ["year", "trove_article_heading", "heading", "date", "snippet", "id"]:
            if (field_name in trove_result_df):
                summary_fields.append(field_name)
        print(trove_result_df[summary_fields])



