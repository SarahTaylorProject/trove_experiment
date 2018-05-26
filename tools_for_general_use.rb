require "csv"
require "net/http"
require "date"
require "rbconfig"

def say_something(text, also_print = true, speed = 180)
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


def get_user_int_array(prompt_text = "\nPlease enter integer values...", divider = ",")
   # reads user input to an integer array
   # not very fancy error trapping: it will all fail if there is one non-integer value
   result = false
   begin
      input_string = get_user_input(prompt_text = prompt_text + " (use '#{divider}' as the divider)")
      input_string = get_user_input(prompt_text = prompt_text)
      result = return_int_array_from_string(input_string = input_string, divider = divider)
      return(result)
   rescue
      puts("Sorry, error converting input to integer array.")
      return(result)
   end
end


def return_int_array_from_string(input_string, divider = ",")
   # convert input to an integer array
   # not very fancy error trapping: it will all fail if there is one non-integer value
   result = false
   begin
      input_array = input_string.split(divider)
      int_array = input_array.map { |int_string|
         int_string.to_i
      }
      return(int_array)
   rescue
      puts("Sorry, error converting input to integer array.")
      return(result)
   end
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


def return_year_from_date_string(text)
   new_date_array = text.split(/\/|\-/).map(&:to_i)
   new_date = Date.new(*new_date_array)
   new_date.year
end
