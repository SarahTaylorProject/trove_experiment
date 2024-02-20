#from tools_for_poetry_mashup import *
import nltk
import os
import random
import sys

sys.path.insert(0, '..')

from tools_for_general_use import get_user_input
from tools_for_poetry_mashup import read_text_file_to_array

from pathlib import Path

from nltk.tokenize import RegexpTokenizer
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords

stop_words = set(stopwords.words('english'))
stop_words.add('ye')
stop_words.add('thee')
stop_words.add('thou')
stop_words.add('thy')
stop_words.add('aye')

tokenizer = RegexpTokenizer(r'\w+')

maximum_line_count = None
corpus_word_count = 250

#### CHOOSING CORPUS
corpus_file_id_list = [file_id for file_id in nltk.corpus.gutenberg.fileids()]

# will default to moby dick unless 'random' passed to command line
corpus_file_id = 'melville-moby_dick.txt'
if len(sys.argv) > 1:
    command_input = sys.argv[1].strip().lower()
    print(f"Command line input: {command_input}")
    if (command_input == 'random'):
        corpus_file_id = random.choice(corpus_file_id_list)
    else:
        matching_file_list = [file_id for file_id in corpus_file_id_list if command_input in file_id]
        print(matching_file_list)
        if (matching_file_list):
            corpus_file_id = random.choice(matching_file_list)
        else:
            print(f"Could not find corpus like {command_input}")

print(f"Gutenberg text: {corpus_file_id}")

## SIMPLE STEPS TO GET LIST OF COMMON WORDS, WITH TAGS
# TODO: convert to function when ironed out
corpus_raw = nltk.corpus.gutenberg.raw(corpus_file_id)
corpus_words_all = tokenizer.tokenize(corpus_raw)
corpus_words = [w.lower() for w in corpus_words_all if w.lower() not in stop_words]
freq = nltk.FreqDist(corpus_words)
corpus_word_freq = freq.most_common(corpus_word_count)
#print(corpus_word_freq)
corpus_common_words = [word_freq[0] for word_freq in corpus_word_freq]
corpus_common_words_tagged = nltk.pos_tag(corpus_common_words)
# print(corpus_common_words_tagged)

# 1. look for local directory, create if needed
local_input_directory_name = os.path.dirname(os.path.abspath(__file__)) 
local_input_directory_name += os.path.normpath("/") + "songs" + os.path.normpath("/")
print("Searching for input files in: {}".format(local_input_directory_name))

# 2. build dictionaries from files in the input directory
local_input_file_list = os.listdir(local_input_directory_name)
file_dictionary = {index: x for index, x in enumerate(local_input_file_list, start=1)}
choice_dictionary = {index: Path(x).stem.title() for index, x in enumerate(local_input_file_list, start=1)}

# 3. ask for choice of file
print("***\n")
greeting_string = "Which song would you like to work with?"
print(greeting_string)
for index, key in choice_dictionary.items():
    print("{}: {}".format(index, key))
file_number_input = get_user_input(prompt_text = "?")
if (file_number_input.isnumeric()):
    file_number = int(file_number_input)
    if (file_number in choice_dictionary.keys()):
        input_file_name = file_dictionary[file_number]
    else:
        print("Not in list, exiting...")
        sys.exit()
else:
    print("Not in list, exiting...")
    sys.exit()

# 5. read in song file
full_input_file_name = local_input_directory_name + os.path.normpath("/") + input_file_name
input_lines = read_text_file_to_array(full_input_file_name)

print("\n")

for current_song_line in input_lines:
    add_random_word = random.choice([True, True])
    word_list = word_tokenize(current_song_line)
    word_list_tagged = nltk.pos_tag(word_list)
    last_word = word_list_tagged[-1]
    #print(last_word)
    choice_list = [word[0] for word in corpus_common_words_tagged if word[1] == last_word[1]]
    #print(len(choice_list))
    if (choice_list):
       random_word = random.choice(choice_list)
    else:
       random_word = random.choice(corpus_words)
    #    # TODO: consider making lists of each tag type, have used lazy option of just tagging all common words
    #print(random_word)
    word_list[-1] = random_word
    print(" ".join(word_list))

print("\n")
print(f"Gutenberg text: {corpus_file_id}")