import csv
import os
import pathlib
import sys
import traceback
import subprocess
from pathlib import Path

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')
    return()

def return_script_directory():
    script_directory = os.path.dirname(os.path.abspath(__file__))
    return(script_directory)

def return_parent_directory(input_directory):
    parent_directory = Path(input_directory).parent.absolute()
    return(parent_directory)

def return_operating_system():
  """
  Returns a string of the operating system currently in use
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


def test_say_something(text="test", speed=120, espeak_executable_path='C:\Elevate\eSpeak NG\espeak-ng.exe'):
  """
  Test of say_something: useful to include a call to this before using say_something repeatedly
  Returns True if no error
  Returns False if error
  """
  result = False
  try:
    os_result = return_operating_system()
    command_text = None
    if os_result == "mac":
      command_text = 'say -r ' + ' "' + text + '"'
    elif (os.path.isfile(espeak_executable_path)):
      command_text = '"{0}" -s {1}'.format(espeak_executable_path, speed)
      command_text += ' "' + remove_nuisance_characters_from_string(text) + '"'
    elif os_result == "win32":
      command_text = 'espeak -s' + str(speed) + ' "' + text + '"'
    elif os_result == "linux":
      command_text = "echo '" + text + "'|espeak -s " + str(speed)

    if (command_text != None):
      subprocess.check_output(command_text)
      result = True

    return(result)
 
  except:
    return(result)


def say_something(text, also_print=True, try_say=True, speed=120, espeak_executable_path='C:\Elevate\eSpeak NG\espeak-ng.exe'):
  """
  Says text aloud through the command line for some operating systems
  Checks for operating system and uses appropriate say-aloud command line
  Works for linux and mac, and for Windows if the 'espeak' package is installed.
  If try_say is passed in as False, it will not bother with trying to say stuff
  If also_print is True, then the text is sent to puts as well
  """

  if (also_print == True):
    print(text)
  if (try_say == False):
    return()

  os_result = None
  os_result = return_operating_system()
  command_text = None

  if os_result == "mac":
    command_text = 'say -r ' + str(speed) + ' "' + text + '"'
  elif (espeak_executable_path != None and os.path.isfile(espeak_executable_path)):
    print("here")
    command_text = '"{0}" -s {1}'.format(espeak_executable_path, speed)
    command_text += ' "' + remove_nuisance_characters_from_string(text) + '"'
  elif os_result == "win32":
    command_text = 'espeak -s' + str(speed) + ' "' + text + '"'
  elif os_result == "linux":
    command_text = "echo '" + text + "'|espeak -s " + str(speed)

  if (command_text != None):
    subprocess.call(command_text, shell=True)
  else:
    return()


def get_user_input(prompt_text = "\nPlease enter value"):
  # This method just gets direct input from the user with a prompt
  # Returns the user input
  # Tried two options for Python input: rawinput or input (one is in each function below)
  # If the 'input' function returns False, it will try the 'rawinput' function
  # Returns input_text for user input, which will be False if both functions failed
  result = False
  try:
    if (sys.version_info > (3, 0)):
      input_text = input(prompt_text)
    else:
      input_text = raw_input(prompt_text)

    input_text = input_text.strip()
    return(input_text)
  except:
    traceback.print_exc()
    return(result)


def remove_nuisance_characters_from_string(input_string):
  """
  This function is a workaround for the bug that Python 3 decoding doesn't work.
  It removes some typical UTC characters that may be returned from API calls and problematise use of a string in an email header.
  """
  try:
    input_string = input_string.replace('\n', ' ')
    input_string = input_string.replace(u"\u201c", "'")
    input_string = input_string.replace(u"\u201d", "'")
    input_string = input_string.replace(u"\u2014", "")
    input_string = input_string.replace(u"\u2018", "")
    input_string = input_string.replace(u"\u2019", "")
    input_string = input_string.replace('  ', ' ')
    return(input_string)
  except:
    traceback.print_exc()
    return(input_string)
  

def return_matching_file_names(input_path_name='', file_extension='', file_pattern=''):
    """"
    Returns file list for any files matching the pattern and/or extension
    Useful for matching within subdirectories
    """
    matching_file_names = []
    input_path = pathlib.Path(input_path_name).absolute()
    for file in input_path.glob(file_pattern):
        if (file_extension in file.suffix):
            matching_file_names.append(str(file))
    return(matching_file_names)


def return_first_line_of_csv_file(input_csv_file):
    result = None
    try:
        with open(input_csv_file, "r") as f:
            data = list(csv.reader(f))
            first_line = data[1]
        return(first_line)
    except:
        return(result)
    

def return_line_count_of_csv_file(input_csv_file):
    result = None
    try:
        with open(input_csv_file, "r") as f:
            data = list(csv.reader(f))
            line_count = len(data) - 1
        return(line_count)
    except:
        return(result)