from tools_for_poetry_mashup import *
import os
from pathlib import Path

maximum_line_count = None

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
  word_token_list = word_tokenize(current_song_line)
  random_word = "Moby Dick"
  word_token_list[-1] = random_word
  print(" ".join(word_token_list))

print("\n")
