import subprocess
import os
import requests
import traceback
from lxml import etree

# GENERAL FUNCTIONS

def return_operating_system():
  """
  This function returns a string of the operating system currently in use
  """
  result = ""
  from sys import platform
  if platform == "linux" or platform == "linux2":
    result = "linux"
  elif platform == "darwin":
    result = "mac"
  elif platform == "win32":
    result = "win32"
  return(result)


def say_something(text, also_print = True, speed = 120):     
  """
  # Adapted from original Ruby script, August 2017 
  # This function says text aloud through the command line for some operating systems
  # It checks for operating system and uses appropriate say-aloud command line
  # Works for linux and mac, could expand to others later
  # Will print text either way
  # If also_print is true, then the text is sent to puts as well
  """

  if (also_print == True):
      print(text)
 
  os_result = return_operating_system()
  can_say = False

  if os_result == "mac":
    command_text = "say -r " + str(speed) + "'" + text + "'"
    can_say = True
  elif os_result == "win32":
    command_text = 'espeak -s' + str(speed) + ' "' + text + '"'
    can_say = True
  elif os_result == "linux":
    command_text = "echo '" + text + "'|espeak -s " + str(speed)
    can_say = True


  if (can_say == True):
    subprocess.call(command_text, shell=True)
  else:
    print("\t(say_something does not yet support this operating system)")


def send_instruction(text, SPEAK_INSTRUCTIONS=False):
  # Adapted from Ruby method 20171206
  # This function will say instructions out loud IF the environment permits this
  # otherwise it will just send the text to print
  # It will not ask say_something to print it again!

  print(text)

  if (SPEAK_INSTRUCTIONS == True):
    say_something(text, also_print=False)


def get_user_input(prompt_text = "\nPlease enter value"):
  # Adapted from Ruby method 20171206
  # This method just gets direct input from the user with a prompt
  # Returns the user input
  # Nothing fancy, just a handy function
  input_text = input(prompt_text)
  input_text = input_text.strip()
  return(input_text)


def clear_screen():
  os_result = return_operating_system()
  if os_result == "win32":
    subprocess_result = subprocess.check_call("cls", shell=True)
  elif os_result == "mac":
    subprocess_result = subprocess.check_call("clear", shell=True)

# TROVE-SPECIFIC FUNCTIONS

def fetch_trove_results(current_search_town, current_search_word, trove_key):
  # In the process of adapting from Ruby, December 2017
  # This method constructs a single search request for Trove (of a very specific format!) 
  # Input: two search parameters (town name, and search term) and the API key 
  # Return: XML of results (if successful) or 0 if error encountered
  # Note: will not necessarily fail if no results returned
  # The search town and search term are currently both just passed as strings, eventually the town search will be expanded
  result = False
  try:
    #substitute spaces for Trove API
    current_search_word = current_search_word.replace(" ", '%20')
    current_search_town = current_search_town.replace(" ", '%20')

    trove_api_request = "http://api.trove.nla.gov.au/result?key="
    trove_api_request += trove_key +"&zone=newspaper&encoding&q=" + current_search_word + "+AND+" + current_search_town
    print(trove_api_request)

    api_result = requests.get(trove_api_request)
    trove_api_results = etree.parse(api_result.content)
    # return(trove_api_results)
    # if (result.status_code == 200):
    #   print("Success!")
    #   trove_api_results = etree.parse(result.content)
      #print(trove_api_results)
    return(trove_api_results)
    # MUST PARSE XML HERE
    #trove_api_results = Nokogiri::XML.parse(`curl "#{trove_api_request}"`)
  except:
    traceback.print_exc()
    return(result) 


## MAIN

SPEAK_INSTRUCTIONS = False
clear_screen()

text = "Testing Python conversion."
send_instruction(text, SPEAK_INSTRUCTIONS)

to_continue = True
clear_screen()
print("\nSTART TROVE EXPERIMENT ******\n")

# my Trove API key and default searches
my_trove_key = "lop9t29sfm35vfkq"
default_town = "Elmore"
default_word = "tragedy"

print("Hello. This is an experiment. I can call the olden days. I make use of the National Library of Australia Trove database.")
print("I send a search request to the Trove API, with your nominated search town and search word.")
print("All results will be written to a csv file that you can keep. I will then proceed with a live reading.")
print("You will have a chance to curate the articles, before I preceed with the live reading.")

send_instruction("Hello. This is an experiment. I can call the olden days. I make use of the National Library of Australia Trove database.", SPEAK_INSTRUCTIONS)

send_instruction("Please enter a search town in Australia. (This will default to '" + default_town + "', you can press enter to leave this unchanged, or type 'exit' to escape)", SPEAK_INSTRUCTIONS)
search_town = get_user_input("")

if (len(search_town) == 0):
  search_town = default_town
elif (search_town.lower() == "exit"):
   to_continue = False

if (to_continue == True):
  send_instruction("Please enter a search word. (This will default to '" + default_word + "', you can press enter to leave this unchanged, or type 'exit' to escape)", SPEAK_INSTRUCTIONS)
  search_word = get_user_input("")

  if (len(search_word) == 0):
    search_word = default_word
  elif (search_word.lower() == "exit"):
    to_continue = False

if (to_continue == True):
  send_instruction("Search town is " + search_town, SPEAK_INSTRUCTIONS)
  send_instruction("Search word is " + search_word, SPEAK_INSTRUCTIONS)

if (to_continue == True):
  send_instruction("\nThankyou. Calling the olden days about " + search_town + " " + search_word, SPEAK_INSTRUCTIONS)
  send_instruction("Connecting to Trove database now.", SPEAK_INSTRUCTIONS)

  trove_api_results = fetch_trove_results(current_search_town=search_town, current_search_word=search_word, trove_key=my_trove_key)
  print("HERE\n")
  print(type(trove_api_results))
  output_file_name = "trove_result_" + search_town + "_" + search_word + ".csv"

  #print(type(trove_api_results))
  exit()
  print("\nWriting all results to file now...")
  result_count = write_trove_results(trove_api_results, output_file_name, search_word, search_town)

  print("\nSearch town:\n", search_town)
  print("\nSearch word:\n", search_word)
  print("\nResult count:\n", result_count)
  print("\nResult written to:\n", output_file_name)