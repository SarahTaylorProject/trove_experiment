load 'tools_for_talking.rb'
load 'tools_for_trove.rb'
load 'tools_for_digital_death_trip.rb'
require 'fileutils'

clear_screen()
my_trove_key = read_trove_key()
search_word = 'tragedy'
default_speed = 180
default_output_path = File.join(Dir.pwd, 'output_files')
unless File.directory?(default_output_path)
   FileUtils.mkdir_p(default_output_path)
end
default_town_path_name = File.join(Dir.pwd, 'town_lists')
max_articles_to_read = 3
standard_town_data_types = ['S for existing PTV Stop files', 'P for PTV GTFS zip file', 'V for VICMAP']
continue = true

say_something("Hello, this is Digital Death Trip.", also_print = true, speed = default_speed)
say_something("Today I am talking to you from a #{operating_system()} operating system.", also_print = true, speed = default_speed)

say_something("Would you like to choose a town, or would you like me to make a random selection?", also_print = true, speed = default_speed)
input_choice = get_user_input(prompt_text = "Enter town name OR 'random'")

if (input_choice.upcase == 'RANDOM') then

   say_something("Please choose a data source for me to gather town names from.", also_print = true, speed = default_speed)
   instruction_string = "\nI can search in: "
   standard_town_data_types.each do |data_type|
     instruction_string += "\n\t'" + data_type + "'"
   end
   instruction_string += "\nWhich would you like me to use? I will default to #{standard_town_data_types[0]}"
   source_choice = get_user_input(prompt_text = instruction_string)
   if (source_choice.length == 0) then
      source_choice = standard_town_data_types[0]
   end

   vic_town_list = return_town_list(source_type = source_choice, main_path_name = default_town_path_name)
   puts(vic_town_list)
   if (vic_town_list == false) then
      say_something("I'm sorry, I encountered an error, please check and try again.", also_print = true, speed = default_speed)
      return(false)
   elsif (vic_town_list.size == 0) then   
      say_something("I'm sorry, I couldn't find any towns, please check and try again.", also_print = true, speed = default_speed)
      return(false)
   else
      say_something("I found #{vic_town_list.length} unique Victorian towns in this data.", also_print = true, speed = default_speed)
      try_again = true
      while (continue == true and try_again == true) do
         search_town = vic_town_list.sample
         say_something("My random town choice is #{search_town}", also_print = true, speed = default_speed)      
         say_something("What do you think?", also_print = true, speed = default_speed)
         user_input = get_user_input(prompt_text = "Enter 'n' to try again, \nEnter 'exit' to cancel and exit, \nEnter any other key to continue with this town choice...")
         if (user_input.upcase == 'EXIT') then
            continue = false
         elsif (user_input.upcase == 'N') then
            try_again = true
         else
            try_again = false
         end
      end
   end

else
   search_town = input_choice
end

if (continue == true) then
   say_something("I will now see if I can find any newspaper references to a #{search_word} in #{search_town}")
   output_file_name = File.join(default_output_path, "trove_result_#{search_town}_#{search_word}.csv".gsub(/\s/,"_"))
   puts(output_file_name)
   trove_api_results = fetch_trove_results(search_town, search_word, my_trove_key)
   puts("\nWriting results to file now...")
   result_count = write_trove_results(trove_api_results, output_file_name, search_word, search_town)
   puts(result_count)

   result_count = preview_trove_results(output_file_name)
   if (result_count == 0) then
      continue = false
      say_something("\nSorry, no tragedy results found for #{search_town}")
   else
      say_something("Would you like me to read the headlines?", also_print = true, speed = default_speed)
      user_input = get_user_input(prompt_text = "\nEnter 'n' if not interested, \nEnter 'exit' to cancel entirely, \nEnter any other key to hear headlines...")
      say_something("\nHere are the dates and headlines...")
      if (user_input.upcase == 'EXIT') then
         continue = false
      elsif (user_input.upcase != 'N') then
         read_trove_headlines(input_trove_file = output_file_name, speed = default_speed)
      end
   end
end

default_article_numbers = [1, 2, 3, 4]
while (continue == true) do   
   clear_screen()
   result_count = preview_trove_results(output_file_name)
   say_something("\nWould you like me to read any article content?", also_print = true, speed = default_speed)  
   user_input = get_user_input(prompt_text = "\Please enter article numbers separated by space or comma. \nEnter 'n' or exit' to cancel.\nI will default to #{default_article_numbers}")
         
   if (user_input.upcase == 'N' or user_input.upcase == 'EXIT') then
      continue = false
   else
      article_numbers = return_int_array_from_string(user_input, divider = ",")
      if (article_numbers == false) then
        article_numbers = return_int_array_from_string(user_input, divider = " ")
      end           

      if (article_numbers == false) then
         continue = false
      elsif (article_numbers.size == 0) then
         article_numbers = default_article_numbers
      end
   end

   if (continue == true) then
      say_something("Ok. I will now read previews of articles #{article_numbers}", also_print = true, speed = default_speed)
      read_trove_results_by_array(input_trove_file = output_file_name, article_numbers = article_numbers, speed = default_speed)
   end
end

say_something("\nThank you, goodbye.", also_print = true, speed = default_speed)