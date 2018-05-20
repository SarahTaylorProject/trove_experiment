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
default_town_path = File.join(Dir.pwd, 'town_lists')
max_articles_to_read = 3
standard_town_data_types = ['SAMPLE PTV STOP FILE', 'PTV GTFS', 'VICMAP']

say_something("Hello, this is Digital Death Trip.", also_print = true, speed = default_speed)
say_something("Today I am talking to you from a #{operating_system()} operating system.", also_print = true, speed = default_speed)

say_something("Would you like to choose a town, or would you like me to make a random selection?", also_print = true, speed = default_speed)
input_choice = get_user_input(prompt_text = "Enter town name OR 'random'")

if (input_choice.upcase == 'RANDOM') then

   instruction_string = "Please choose a data source for me to gather town names from."
   say_something(instruction_string, also_print = false, speed = default_speed)
   instruction_string += "\nI can search in: "
   standard_town_data_types.each do |data_type|
     instruction_string += "\n\t'" + data_type + "'"
   end
   instruction_string += "\nWhich would you like me to use? I will default to #{standard_town_data_types[0]}"
   source_choice = get_user_input(prompt_text = instruction_string)
   if (source_choice.length == 0) then
      source_choice = standard_town_data_types[0]
   end

   vic_town_list = return_standard_town_list(source_type = source_choice, path_name = default_town_path)
   if (vic_town_list == false) then
      say_something("I'm sorry, I encountered an error, please check and try again.", also_print = true, speed = default_speed)
      return(false)
   elsif (vic_town_list.size == 0) then   
      say_something("I'm sorry, I couldn't find any towns, please check and try again.", also_print = true, speed = default_speed)
      return(false)
   else
      say_something("I found #{vic_town_list.length} unique Victorian towns in this data.", also_print = true, speed = default_speed)
      continue = false
      while (continue == false) do
         search_town = vic_town_list.sample
         say_something("My random town choice is #{search_town}", also_print = true, speed = default_speed)      
         say_something("\nWhat do you think?", also_print = true, speed = default_speed)
         user_choice = get_user_input(prompt_text = "Press 'n' to try again, or press any key to continue...")
         if (user_choice.upcase == 'N') then
            continue = false
         else
            continue = true
         end
      end
   end

else
   search_town = input_choice
end

say_something("I will now see if I can find any newspaper references to a #{search_word} in #{search_town}")
output_file_name = File.join(default_output_path, "trove_result_#{search_town}_#{search_word}.csv".gsub(/\s/,"_"))
puts(output_file_name)
trove_api_results = fetch_trove_results(search_town, search_word, my_trove_key)
puts("\nWriting results to file now...")
result_count = write_trove_results(trove_api_results, output_file_name, search_word, search_town)
puts(result_count)

continue = true
say_something("Previewing results now on the screen...")
result_count = preview_trove_results(output_file_name)
if (result_count > 0) then
   while (continue == true) do
      default_article_numbers = [1, 2, 3]
      say_something("\nFinishing previewing results. Which articles would you like me to read aloud?")
      article_numbers = get_user_int_array(prompt_text = "\nPlease enter article number choices, I will default to #{default_article_numbers}", divider = ",")
      if (article_numbers.size == 0) then
         article_numbers = default_article_numbers
      end
      say_something("Ok. I will now read previews of these articles.")
      puts("#{article_numbers}")
      read_trove_results_by_array(input_trove_file = output_file_name, article_numbers = article_numbers)
      clear_screen()
      say_something("\nFinished reading articles #{article_numbers}. Would you like me to read more articles aloud?", also_print = true, speed = default_speed)
      prompt_text = "Press any key to continue, or 'exit' or 'n' to exit"
      user_choice = get_user_input(prompt_text = prompt_text)
      puts(user_choice)
      if (user_choice.upcase == 'N' or user_choice.upcase == 'EXIT') then
         continue = false
      else
         result_count = preview_trove_results(output_file_name)
      end
   end
else
   say_something("I'm sorry, no results found for this town, please try again.", also_print = true, speed = default_speed)
end

say_something("\nThankyou, goodbye.", also_print = true, speed = default_speed)