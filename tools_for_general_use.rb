require "csv"
require "net/http"
require "date"
require "rbconfig"


def clear_screen()
   system("clear")
end


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



def unzip_single_file(input_file_name, input_path_name=nil, overwrite=true, output_path_name=nil)
   # unzips a single zip file
   # returns the output path if successful, or false if error encountered
   # if output_path_name is left as nil then it will construct a default output location using zip file norms
   # tries the '7z' function first, then the 'unzip' command
   result = false
   begin
      
      if (input_path_name != nil) then
         full_zip_file_name = File.join(input_path_name, input_file_name)
      else
         full_zip_file_name = input_file_name
      end
      
      if (output_path_name == nil) then
         if (input_path_name == nil) then
            full_output_path_name = File.dirname(full_zip_file_name)
         else   
            full_output_path_name = File.join(input_path_name, File.basename(full_zip_file_name, '.zip'))
         end
      else
         full_output_path_name = output_path_name
      end

      print("\n1. First trying unzip with '7z'")
      unzip_result = unzip_file_with_7z_command(full_zip_file_name = full_zip_file_name, full_output_path_name = full_output_path_name, overwrite = overwrite, use_7za_suffix = false)
      print(unzip_result)
      if (unzip_result == false) then
         print("\n2. Now trying unzip with '7za'")
         unzip_result = unzip_file_with_7z_command(full_zip_file_name = full_zip_file_name, full_output_path_name = full_output_path_name, overwrite = overwrite, use_7za_suffix = true)
         print(unzip_result)
      end
      if (unzip_result == false) then
         print("\n3. Now trying unzip with 'unzip'")
         unzip_result = unzip_file_with_unzip_command(full_zip_file_name = full_zip_file_name, full_output_path_name = full_output_path_name, overwrite = overwrite)      
         print(unzip_result)
      end
   
      if (unzip_result == true) then
         return(full_output_path_name)
      else
         return(result)
      end

   rescue   
      puts("FunctioN: unzip_single_file, error encountered with unzipping #{input_file_name}") 
      return(result)
   end
end


def unzip_file_with_unzip_command(full_zip_file_name, full_output_path_name=nil, overwrite=true)
   # tries unzipping a file with the 'unzip' command, returns true if successful, false if error encountered
   result = false
   begin
      puts("\nFunction: unzip_file_with_unzip_command")
      command_string = "unzip "
      if (overwrite == true) then
         command_string += "-o "
      end
      command_string += full_zip_file_name
      if (full_output_path_name != nil) then
         command_string += " -d " + full_output_path_name
      end
      puts("Command:")
      puts(command_string)
      system_result = system(command_string)
      puts(system_result)
      if (system_result == true) then
         puts("system_result == true, Successfully unzipped #{full_zip_file_name} to #{full_output_path_name} with this command")         
         result = true
      else
         puts("system_result != true, Non-zero exit code, could not successfully unzip to #{full_zip_file_name} to #{full_output_path_name} with this command")
      end
      return(result)
   rescue
      puts("Function: unzip_file_with_unzip_command, error encountered with unzipping #{full_zip_file_name} to #{full_output_path_name}")
      return(result)
   end
end


def unzip_file_with_7z_command(full_zip_file_name, full_output_path_name=nil, overwrite=true, use_7za_suffix=true)
   # tries unzipping a file with the 'unzip' command line, returns true if successful, false if error encountered
   result = false
   begin
      puts("\nFunction: unzip_file_with_7z_command")
      command_string = "7z"            
      if (use_7za_suffix == true) then
         puts("Using suffix: '7za'")
         command_string += "a"
      end
      command_string += " x " 
      if (overwrite == true) then
         command_string += "-aoa "
      end
      command_string += full_zip_file_name
      if (full_output_path_name != nil) then
         command_string += " -o" + full_output_path_name
      end
      puts("Command:")
      puts(command_string)
      system_result = system(command_string)
      puts(system_result)
      if (system_result == true) then
         puts("system_result == true, successfully unzipped #{full_zip_file_name} to #{full_output_path_name} with this command")         
         result = true
      else
         puts("system_result != true, could not successfully unzip to #{full_zip_file_name} to #{full_output_path_name} with this command")
      end
      return(result)
   rescue
      puts("Function: unzip_file_with_7z_command, error encountered with unzipping #{full_zip_file_name} to #{full_output_path_name}")
      return(result)
   end
end


def convert_phrase_string_for_url(input_string, input_divider = ' ', output_quotemark='%22', output_divider='%20')
   # changes a phrase string with spaces, to string suitable for use in a URL
   # treats as a single phrase, not as separate words
   # (i.e. puts a URL-friendly quote symbol at the start and end, and URL-friendly dividers in the middle)
   # https://www.w3schools.com/tags/ref_urlencode.asp
   begin

      input_words = input_string.split(input_divider)
      if (input_words.size == 1) then
         return(input_string)
      end
      
      output_string = output_quotemark
      for word in input_words.each do
         output_string += (word + output_divider)
      end

      output_string = output_string[0..output_divider.size] + output_quotemark

      return(output_string)
   rescue
      return(input_string)
   end
end


def proper_case(input_string)
   begin
      output_string = input_string.split(" ").map { |word|
         word.capitalize
      }.join(" ")
      return(output_string)
   rescue
      return(input_string)
   end
end


def return_matching_file_names(input_path_name = Dir.pwd, file_extension = "", file_pattern="")
   # this function returns file list for any files matching the pattern and/or extension
   # useful for matching within subdirectories
   matching_file_names = []
   Find.find(input_path_name) do |path|
      if path =~ /.*\.#{file_extension}/ then
         if path =~ /.*#{file_pattern}./ then
            matching_file_names << path
         end
      end
   end
   return(matching_file_names)
end