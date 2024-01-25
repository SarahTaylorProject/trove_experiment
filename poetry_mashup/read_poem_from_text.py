from tools_for_poetry_mashup import *
import os
import codecs
import sys

try_say = test_say_something()
print(try_say)

default_speed = 170
maximum_line_count = None
read_text_file = False

# 1. look for local directory, create if needed
local_input_directory_name = os.path.dirname(os.path.abspath(__file__)) + os.path.normpath("/") + "poetry_input_files_current" + os.path.normpath("/")
print("Searching for local input files in: {}".format(local_input_directory_name))
if not os.path.isdir(local_input_directory_name):
  print("No local input directory found, I will create one. \nPlease put your poetry input material here in future: {}".format(local_input_directory_name))
  os.makedirs(local_input_directory_name)
  sys.exit()

# 2. build a local input dictionary from all the files in the input directory
local_input_file_list = os.listdir(local_input_directory_name)
choice_dictionary = {index: x for index, x in enumerate(local_input_file_list, start=1)}
choice_dictionary['(any other key to exit)'] = None
print(choice_dictionary)

# 3. ask for choice of file file
print("***\n")
greeting_string = "Which file would you like me to read?"
print(greeting_string)
for index, key in choice_dictionary.items():
  print("{}: {}".format(index, key))
file_number_input = get_user_input(prompt_text = "?")
if (file_number_input.isnumeric()):
  file_number = int(file_number_input)
  if (file_number in choice_dictionary.keys()):
    input_file_name = choice_dictionary[file_number]
    read_text_file = True

# 4. ask if maximum lines

greeting_string = "\nWhat is the maximum number of lines you would like me to read out?"
print(greeting_string)
max_lines_input = get_user_input(prompt_text = "(default {})\n".format(maximum_line_count))
if (max_lines_input.isnumeric()):
  maximum_line_count = int(max_lines_input)

# 5. read in file, and then make subset if maximum lines, then read each line aloud
if (read_text_file == True):

  full_input_file_name = local_input_directory_name + os.path.normpath("/") + input_file_name
  input_lines = read_text_file_to_array(full_input_file_name)

  if (maximum_line_count != None):
    read_line_count = min(maximum_line_count, len(input_lines))
    read_lines = [remove_nuisance_characters_from_string(line) for line in input_lines[:read_line_count]]
  else:
    read_lines = input_lines

  for current_line in read_lines:

    say_something(text=current_line, try_say=try_say, speed=default_speed)


print("\n")