import subprocess
import os

# This function returns a string of the operating system currently in use
def return_operating_system():
    result = ""
    from sys import platform
    if platform == "linux" or platform == "linux2":
        result = "linux"
    elif platform == "darwin":
        result = "mac"
    elif platform == "win32":
        result = "win32"
    return(result)

# This function says text aloud through the command line for some operating systems
# It checks for operating system and uses appropriate say-aloud command line
# Works for linux and mac, could expand to others later
# Will print text either way
# If also_print is true, then the text is sent to puts as well
# Adapted from original Ruby script, August 2017
def say_something(text, also_print = True, speed = 120):
       
   if (also_print == True):
      print(text)
 
   os_result = return_operating_system()
   can_say = False

   if os_result == "linux":
      #command_text = `echo "#{text}"|espeak -s #{speed}`
      command_text = "echo '" + text + "'|espeak -s " + str(speed)
      can_say = True
   elif os_result == "mac":
      #command_text = `say -r #{speed} "#{text}"`
      command_text = "say -r " + str(speed) + "'" + text + "'"
      can_say = True

   if (can_say == True):
       subprocess.call(command_text, shell=True)
   else:
      print("\t(say_something does not yet support this operating system)")

