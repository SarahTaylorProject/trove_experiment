require "csv"
require "net/http"
require "date"
require "rbconfig"


def say_something(text, also_print = true, speed = 150)
   # This method says text aloud through the command line
   # Checks for operating system and uses appropriate say-aloud command line
   # Works for linux and mac, could expand to others later
   # Will print text either way
   # If also_print is true, then the text is sent to puts as well
 
   if (also_print == true) then
      puts(text)
   end

   result = operating_system()

   case result
      when "linux"
         `echo "#{text}"|espeak -s #{speed}`
      when "mac"
         `say -r #{speed} "#{text}"`
      when "windows"
         `espeak -s#{speed} "#{text}"`
      else
         puts "say_something does not yet support this operating system"
   end     

end

def say_instruction(text)
   # This method will say instructions out loud IF the environment permits this
   # otherwise it will just send the text to puts
   # It will not ask say_something to print it again!

   puts(text)

   if(ENV["SAY_EVERYTHING"] == "true") then
      say_something(text, also_print = false)
   end 

end

def get_user_input(prompt_text = "\nPlease enter value")
   # This method just gets direct input from the user with a prompt
   # Returns the user input
   # Nothing fancy, just a handy function

   if (prompt_text.length > 0) then
      puts prompt_text  
   end
   input_text = STDIN.gets.chomp
   return(input_text)

end

def clear_screen()
   system("clear")
end

def operating_system()
   # This method checks the operating system name and returns this, if it is in the list
   # Requires 'rbconfig' to run
   # Returns "unknown" if operating system is not recognised

   include RbConfig
   os_name = "unknown"

   case CONFIG['host_os']
   when /linux|arch/i
      os_name = "linux"
   when /darwin/i
      os_name = "mac"
   when /mswin|windows/i
      os_name = "windows"
   when /mingw32/i
         os_name = "windows"
   when /sunos|solaris/i
      os_name = "solaris"
   end

   return(os_name)

end

def convert_date(text)
   new_date_array = text.split(/\/|\-/).map(&:to_i)
   new_date = Date.new(*new_date_array)
   new_date.strftime("%Y %d %B")
end


def remove_unfinished_sentence(input_string, divider = ".")
   # This method removes any unfinished sentence from a string
   begin
      if (input_string[-1] == divider) then
         return(input_string)
      end

      output_string = ''
      input_sentence_array = input_string.split(divider)

      if (input_sentence_array.size == 1) then
         return(input_string)
      end

      for sentence in input_sentence_array[0..-2].each do
         output_string += sentence + divider      
      end

      return(output_string)
   rescue
      puts("Error encountered, will return input string.")
      return(input_string)
   end

end


def get_user_input(prompt_text = "\nPlease enter value")
   # This method just gets direct input from the user with a prompt
   # Returns the user input
   # Nothing fancy, just a handy function

   if (prompt_text.length > 0) then
      puts prompt_text  
   end
   input_text = STDIN.gets.chomp
   return(input_text)

end


def say_instruction(text)
   # This method will say instructions out loud IF the environment permits this
   # otherwise it will just send the text to puts
   # It will not ask say_something to print it again!

   puts(text)

   if(ENV["SAY_EVERYTHING"] == "true") then
      say_something(text, also_print = false)
   end 

end