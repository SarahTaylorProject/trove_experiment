load 'tools_for_general_use.rb'
load 'tools_for_trove.rb'
load 'tools_for_towns.rb'
load 'tools_for_geojson.rb'
require 'fileutils'
require 'find'

DEFAULT_ARTICLE_COUNT = 20

clear_screen()
my_trove_key = read_trove_key()
search_word = 'tragedy'
default_speed = 180
default_output_path_name = File.join(Dir.pwd, 'output_files')
unless File.directory?(default_output_path_name)
   FileUtils.mkdir_p(default_output_path_name)
end
default_town_path_name = File.join(Dir.pwd, 'town_lists')
max_articles_to_read = 3

continue = true
output_file_name = ''

# Test for existing file list
existing_trove_file_list = return_existing_trove_file_list(output_path_name = default_output_path_name)
puts("Files already available: #{existing_trove_file_list.size}")
#print_existing_trove_file_list(existing_trove_file_list)
puts("Trove result files already available: #{existing_trove_file_list.size}")

###
#say_something("Hello, this is Digital Death Trip.", also_print = true, speed = default_speed)
#say_something("Today I am talking to you from a #{operating_system()} operating system.", also_print = true, speed = default_speed)

#say_something("\nWould you like to choose a town, or would you like me to make a random selection?", also_print = true, speed = default_speed)
user_input = get_user_input(prompt_text = "Enter town name OR 'random'\nEnter 'random file' or 'rf' for a random existing file (offline)\nEnter 'exit' to cancel")

if (user_input.upcase == 'EXIT') then
   continue = false
elsif ((user_input.upcase == 'RANDOM') or (user_input.upcase == 'R')) then
   search_town = select_random_town_with_user_input(default_speed = default_speed, town_path_name = default_town_path_name)
elsif ((user_input.upcase == 'RANDOM FILE') or (user_input.upcase == 'RF')) then
   puts("\nSelecting random existing Trove file...")
   existing_trove_file_list = return_existing_trove_file_list(output_path_name = default_output_path_name, also_print = true)
   if (existing_trove_file_list.size == 0) then
      puts("sorry, no existing Trove files found")
      continue = false
   else
      output_file_name = existing_trove_file_list.sample
      puts("Selected file: #{File.basename(output_file_name)}")
      search_town = return_trove_file_search_town(output_file_name)
   end
else
   search_town = user_input
end

puts("Search town: #{search_town}")

# nb. need function here to gather coordinates for town choices not made through town_dictionary

if (continue == true and output_file_name == '') then
   say_something("Ok. I will now see if I can find any newspaper references to a #{search_word} in #{search_town}")
   output_file_name = File.join(default_output_path_name, "trove_result_#{search_town}_#{search_word}.csv".gsub(/\s/,"_"))
   trove_api_results = fetch_trove_search_results(search_town, search_word, my_trove_key)
   puts("\nWriting results to file now...")
   result_count = write_trove_search_results(trove_api_results, output_file_name, search_word, search_town)
   puts(result_count)

   if (result_count == 0) then
      continue = false
      say_something("\nSorry, no tragedy results found for #{search_town}")
   end
end

default_article_numbers = Array(1..5)
random_article_range = Array(1..20)

if (continue == true) then
   result_count = count_trove_search_results_from_csv(output_file_name)
   say_something("\nI now have #{result_count} results on file.\nWould you like me to read a few headlines, to get a sense of the tragedies in #{search_town}?", also_print = true, speed = default_speed)
   user_input = get_user_input(prompt_text = "Enter 'n' if not interested, \nEnter 'exit' to cancel entirely, \nEnter 'all' to hear all the headlines, \nEnter any other key to hear a few sample headlines...")
   if (user_input.upcase == 'EXIT') then
      continue = false
   elsif (user_input.upcase == 'ALL') then
      # just reads the default first 5
      read_trove_headlines(input_trove_file = output_file_name, speed = default_speed, article_numbers = default_article_numbers)
   elsif (user_input.upcase != 'N') then
      # reads random sample of 5
      random_article_numbers = Array.new(5) { rand(1..20) }
      read_trove_headlines(input_trove_file = output_file_name, speed = default_speed, article_numbers = random_article_numbers)
   end
end

if (continue == true) then 
   say_something("\nShall I pick a random tragedy from this place? Or let me know if you would like to pick from some specific articles", also_print = true, speed = default_speed)  
end

while (continue == true) do      
   user_input = get_user_input(prompt_text = "\nI will default to a random selection. \nPlease enter 'pick' if you would like to pick. \nEnter 'exit' to cancel.")
   if (user_input.upcase == 'EXIT') then
      continue = false
   elsif (user_input.upcase == 'PICK') then 
      say_something("\nWhich articles are you interested in?", also_print = true, speed = default_speed)  
      user_input = get_user_input(prompt_text = "\Please enter article numbers separated by space or comma. \nEnter 'exit' to cancel.\nI will default to #{default_article_numbers}")   
      if (user_input.upcase == 'EXIT') then
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
         say_something("\nOk, let's see.", also_print = true, speed = default_speed) 
         puts("Articles: #{article_numbers}")
         read_trove_results_by_array(input_trove_file = output_file_name, article_numbers = article_numbers, speed = default_speed)
      end
   else
      random_article_number = random_article_range.sample
      say_something("Ok. Here is my random tragedy from #{search_town}.", also_print = true, speed = default_speed)
      puts(random_article_number)
      # skipping read for now
      #read_trove_results_by_array(input_trove_file = output_file_name, article_numbers = [random_article_number], speed = default_speed)
   end

   if (continue == true) then    
      say_something("\n...That was my random tragedy from #{search_town}. Are you ready to investigate this Trove Town Tragedy?", also_print = true, speed = default_speed)             
      user_input = get_user_input(prompt_text = "\nEnter 'n' for a different tragedy\nEnter 'exit' to cancel\nEnter 'y' to find out more")
      if (user_input.upcase == 'Y') then
         say_something("Good luck!", also_print = true, speed = default_speed)
         puts("HERE")
         # Provision here for full article search
         # note: need to account for multiple article numbers here
         # RECORD LOOKUP NOT WORKING
         trove_article_id = return_record_from_csv_file(input_file = output_file_name, row_number = random_article_number + 1, column_number = 10)
         puts(trove_article_id)
         trove_article_id = return_record_from_csv_file(input_file = output_file_name, row_number = random_article_number + 1, column_number = 3)
         puts(trove_article_id)
         # fetch_trove_newspaper_article(trove_article_id, trove_key)
         continue = false
      elsif (user_input.upcase == 'EXIT') then      
         continue = false
      end
   end
end

# Liz notes
# I think I would like to have some gravitas having read the selected random article.
# Perhaps just say, after the article selection is read, something like:
#“[Pause]. That was my random tragedy from [town name], in [year]. Are you ready to investigate this Trove Town Tragedy?”
#[If enter YES say “Good luck”, and exit.]
#Otherwise “Would you like to try a different tragedy from this place?”
#Then go back to the “shall I pick a random” etc.
#More complex idea is if they are read to investigate  the selection, to then fetch the full article! That's another thing though. 


say_something("\nThank you, goodbye.", also_print = true, speed = default_speed)
exit()

puts("\nWill update map files before exiting...")
current_result = write_geojson_for_all_csv_files(town_path_name = default_town_path_name, output_path_name = default_output_path_name)
if (current_result != false) then
   puts("\nHave written #{current_result} map objects to your output directory.")
   puts("\nYou may find the map files useful.\nYou can open them in QGIS or in Google Maps.")
else
   puts("\nSorry, encountered error with updating map files.")
end
