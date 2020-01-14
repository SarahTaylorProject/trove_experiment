import subprocess
import os
import traceback
import sys

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


def say_something(text, also_print=True, speed=120):
  """
  # Adapted from original Ruby script, August 2017
  # This function says text aloud through the command line for some operating systems
  # It checks for operating system and uses appropriate say-aloud command line
  # Works for linux and mac, and for Windows if the 'espeak' package is installed.
  # Will print text either way
  # If also_print is true, then the text is sent to puts as well
  """

  if (also_print == True):
      print(text)

  os_result = return_operating_system()
  can_say = False

  if os_result == "mac":
    command_text = 'say -r ' + str(speed) + ' "' + text + '"'
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
    return()
    ##print("\t(say_something does not yet support this operating system)")


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

    return(input_text)

  except:
    traceback.print_exc()
    return(result)


def return_random_poetry(author_list=["Browning", "Byron", "Dickinson", "Po", "Shakespeare", "Shelley", "Tennyson", "Wilde"], min_length=8, max_tries=10, full_metadata=True, decode_result=True):
  """
  This function uses the free and open source poetrydb API to select and return a random couplet of poetry (couplet: two successive lines)
  See details of poetrydb format at: https://github.com/thundercomb/poetrydb
  The function sends a request to the poetrydb.org author API, using a RANDOM CHOICE from the input author_list
  Note: the default author_list values are all poets known to be represented in the poetrydb database
  If the API call returns a successful status code, it then loads the result.content as a json object
  The result content is expected to be a dictionary of separate poems by the given author, one dictionary per poem
  The function makes a RANDOM CHOICE from these poems
  If the random poem choice is in the expected format (dictionary), then the function then proceeds to attempt populating
  both the 'metadata' string (a combination of title and author), and the 'random_poetry' string
  The random_poetry is built from a RANDOM CHOICE OF LINE from the list contained under the poem dictionary key 'lines'
  If there are only one line or two lines of poetry, the whole poem is returned
  If there are two are more lines of poetry, it will select a random line (based on a choice between 0 and the poem length),
  and it will pair this into a couplet as follows:
  - if the random choice of line is the last line, add the preceding line
  - if the random choice of is not the last line, add the next line

  If errors are encountered it will return False
  If no errors are encountered it will return AN ARRAY OF TWO STRINGS with the following items:
  0: a random couplet of poetry
  1: the metadata describing the source of this poetry (string with the author and title if full_metadata variable set to True, otherwise just author name)

  If the resulting random poetry is below the minimum length (min_length input, defaulting to 8 characters), it will try again to select
  a random combination of lines from the given poem, up to max_tries

  If any of the expected dictionary keys from poetrydb are missing, the function will exit and return False
  An exception is the 'linecount' key; this is the fastest way to find the length of the poem, but if this key is absent,
  the function will try len(poem_choice["lines"]) instead
  If the poem is not a dictionary it will exit and return False, as this is not the expected format


  """
  result = False
  try:
    import random
    import requests
    import json

    random_poetry = ""
    metadata = ""

    request_string_part1 = "http://poetrydb.org/author/"

    if author_list == []:
      author_list = return_list_of_poets()
      if (author_list == False):
        print("Errors with retrieving author list, exiting.")
        return(result)
      else:
        print("Author list: ", author_list)

    author_choice = random.choice(author_list)
    print("Sending poetry API request for author: %s" %author_choice)
    request_string = request_string_part1 + author_choice
    print(request_string)
    result = requests.get(request_string)
    if (result.status_code == 200):
      if (decode_result == True):
        result_content = result.content.decode("utf-8")
      else:
       result_content = result.content
      result_json = json.loads(result_content)
    else:
      print("No poems found...")
      return(result)

    poem_choice = random.choice(result_json)

    if (isinstance(poem_choice, dict)):
      if (full_metadata == True):
        if ("title" in poem_choice.keys()):
          metadata = metadata + "'" + poem_choice["title"] + "'"
        if ("author" in poem_choice.keys()):
          metadata += " by " + poem_choice["author"]
      else:
        metadata = author_choice

      if ("lines" in poem_choice.keys()):

        if ("linecount" in poem_choice.keys()):
          poem_linecount = int(poem_choice["linecount"])
        else:
          poem_linecount = len(poem_choice["lines"])

        if (poem_linecount == 2):
          random_poetry = poem_choice["lines"][0] + " " + poem_choice["lines"][0]
        elif (poem_linecount == 1):
          random_poetry = poem_choice["lines"][0]
        elif (poem_linecount > 2):
          try_count = 0
          while (len(random_poetry) < min_length and try_count < max_tries):
            poem_line_choice = random.randrange(0, poem_linecount-1)
            print(poem_line_choice)
            random_poetry = poem_choice["lines"][poem_line_choice]
            if (poem_line_choice == poem_linecount):
              random_poetry = poem_choice["lines"][poem_line_choice-1] + " " + random_poetry
            else:
              random_poetry = random_poetry + " " + poem_choice["lines"][poem_line_choice+1]
            try_count += 1
        else:
          print("Insufficient lines of poetry...")
          return(result)

        random_poetry = random_poetry.strip()
        print(random_poetry)
        metadata = metadata.strip()
        print("METADATA: ", metadata)

    else:
      print("Unexpected format...")
      return(result)

    return([random_poetry, metadata])
  except:
    traceback.print_exc()
    return(result)


def return_list_of_poets():
  '''
  Sends request to the poetry DB API for list of authors in their database. Pulls back the names, but as any follow-up
  request for poems requires only the surnames, this function extracts only these surnames, and puts them into a list.

  If successful, returns a list of the surnames of all the poets stored in the API.
  If fails, returns False.
  '''
  result = False
  try:
    request_string_authors = "http://poetrydb.org/author"

    print("Extracting list of all authors in the poetrydb database...")
    result = requests.get(request_string_authors)
    if (result.status_code == 200):
      result_json = json.loads(result.content)
    else:
      print("No poets found...")
      return (result)

    poet_list = []
    for poet in result_json['authors']:
      name_pieces = poet.split()
      poet_list.append(name_pieces[-1])

    return(poet_list)
  except:
    traceback.print_exc()
    return (result)


def return_random_bible(book_list=None, max_chapters=80, max_tries=80, translation='kjv'):
  """
  This function returns a random Bible quote using the API at bible-api.com
  If successful, it returns an array with:
  0: a random Bible verse (string)
  1: metadata about that Bible verse (i.e. which book and verse, from the bible-api.com version)
  It requires a list of books, these will default to the list defined in book_list
  It chooses a random book from this list, then a random chapter, then a random verse
  It doesn't know how many chapters are in each book; it will send an API request until successful (up to a maximum of max_tries)
  """
  result = False
  try:  
    import random
    import requests
    import json
    
    random_bible = ""
    metadata = ""

    if (book_list == None):
      #From https://en.wiktionary.org/wiki/Appendix:Books_of_the_Bible
      book_list = return_bible_book_list()
      if (book_list == False):
        print("Errors with retrieving book list, exiting.")
        return(result)
      else:
        print("Book list: ", book_list)

    request_string_part1 = "https://bible-api.com/"
    
    book_choice = random.choice(book_list)
    request_string_part2 = request_string_part1 + book_choice    
    success = False

    try_count = 0
    while (success == False and try_count < max_tries):   
      if (try_count == max_tries-1):
        chapter_choice = 1
      else:
        chapter_choice = random.randrange(1, max_chapters)
      request_string = request_string_part2 + "+" + str(chapter_choice) + "?translation=" + translation
      print("Trying for random Bible chapter: ", request_string)
      result = requests.get(request_string)
      if (result.status_code == 200):
        result_json = json.loads(result.content)
        print("Chapter found!")
        success = True
      else:
        print("No such chapter, trying again...")
        try_count += 1
    
    if success == False:
      print("Errors encountered, exiting")
      return(result)

    if (isinstance(result_json, dict)):
      if ("reference" in result_json.keys()):
        metadata = result_json["reference"]
        metadata = modify_string_for_email_header(metadata)
      if ("verses" in result_json.keys()):        
        verse_array = result_json["verses"]
    else:
      print("Unexpected format...")
      return(result)

    verse_choice = random.choice(verse_array)

    if (isinstance(verse_choice, dict)):
      if ("verse" in verse_choice.keys()):
        metadata += ":" + str(verse_choice["verse"])      
      if ("text" in verse_choice.keys()):  
        random_bible = verse_choice["text"]
        random_bible = modify_string_for_email_header(random_bible)
       
      print(random_bible)
      print(metadata)

    else:
      print("Unexpected format...")
      return(result)

    return([random_bible, metadata])
  except:
    traceback.print_exc()
    return(result)


def return_bible_book_list():
  '''
  This is a useful but not sophisticated function for returning a list of Bible books recognised by bible-api.com
  It is essentially a placeholder for what I would like to be a dynamic function similar to the return_list_poets()
  Currently it just lists the Bible book names (all of them!) that will be recognised by the Protestant-based bible-api.com

  If successful, returns a list of the surnames of all the Bible books which will be recognised by bible-api.com
  If fails, returns False.
  '''
  result = False
  try:
    bible_book_list = ["genesis", "exodus", "leviticus", "numbers", "deuteronomy", "joshua", "judges", "ruth", 
      "1samuel", "2samuel", "1kings", "2kings", "1chronicles", "2chronicles", "ezra", "nehemiah", "esther",
      "job", "psalms", "proverbs", "ecclesiastes", "songofsolomon", "isaiah", "jeremiah", "lamentations", "ezekiel",
      "daniel", "hosea", "joel", "amos", "obadiah", "jonah", "micah", "nahum", "habbakuk", "zephaniah", 
      "haggai", "zechariah", "malachi",
      "matthew", "mark", "luke", "john", "acts", "1corinthians", "2corinthians", "galatians", "ephesians"
      "matthew", "mark", "luke", "john", "acts", "ephesians", "philippians", "colossians", "1thessalonians", 
      "2thessalonians", "1timothy", "2timothy", "titus", "philemon", "hebrews", "james", "1peter", "2peter", 
      "1john", "2john", "3john", "jude", "revelation"]

    return(bible_book_list)
  except:
    traceback.print_exc()
    return (result)


def read_text_file_to_array(input_file_name, max_lines = None):
  """
  This function is handy for reading in password files.
  It reads a file line by line and returns the lines as an array.
  Returns False if errors encountered.
  If successful, returns an array of strings, one element per input line.
  """
  result = False
  print(input_file_name)
  file_content = []
  line_count = 0
  try:
    input_file = open(input_file_name, 'r')
    for line in input_file:
      line_count += 1
      if (max_lines != None):
        if (line_count > max_lines):
          break
      else:
        file_content.append(line.strip())

    input_file.close()
    return(file_content)
  except:
    traceback.print_exc()
    return(result)

def return_array_of_strings_also_split_by_character(input_array, split_character="."):
  result = input_array
  try:
    if (split_character == None):
      return(input_array)
    output_array = []
    for input_line in input_array:
      if ((split_character in input_line) and (input_line.endswith(split_character) == False)):
        input_line_split = input_line.split(split_character)
        output_array.extend(input_line_split)
      else:
        output_array.append(input_line)
    return(output_array)
  except:
    traceback.print_exc()
    return(result)



def remove_item_from_list(input_list, remove_item=""):
  try:
    for item in input_list:
      if item == remove_item:
        input_list.remove(item)
    return(input_list)
  except:
    traceback.print_exc()
    return(None)


def modify_string_for_email_header(input_string):
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