require 'fileutils'
require 'find'
load 'tools_for_general_use.rb'
load 'tools_for_trove.rb'
load 'tools_for_towns.rb'
load 'tools_for_geojson.rb'

script_directory = File.dirname(__FILE__)

clear_screen()
my_trove_key = read_trove_key()
search_word = 'tragedy'
default_speed = 180
default_output_path_name = File.join(script_directory, 'output_files')
unless File.directory?(default_output_path_name)
   FileUtils.mkdir_p(default_output_path_name)
end
default_town_path_name = File.join(script_directory, 'town_lists')
max_articles_to_read = 3

continue = true
trove_result_file_name = ''

trove_article_id = '35276208'
trove_article_result = fetch_trove_newspaper_article(trove_article_id = trove_article_id, trove_key = my_trove_key)
trove_article_file = write_trove_newspaper_article_to_file(trove_article_result = trove_article_result, trove_article_id = trove_article_id, output_path_name = default_output_path_name)        
puts("HERE!")
exit()

existing_trove_file_list = return_existing_trove_file_list(output_path_name = default_output_path_name)
puts("\nTrove result files already available: #{existing_trove_file_list.size}\n")

say_something("Hello, this is Digital Death Trip.", also_print = true, speed = default_speed)
say_something("Today I am talking to you from a #{operating_system()} operating system.", also_print = true, speed = default_speed)

say_something("\nWould you like to choose a town, or would you like me to make a random selection?", also_print = true, speed = default_speed)
user_input = get_user_input(prompt_text = "Enter town name OR 'random'\nEnter 'random file' or 'rf' for a random existing file (offline)\nEnter 'exit' to cancel")

if (user_input.upcase == 'EXIT') then
   continue = false
elsif ((user_input.upcase == 'RANDOM') or (user_input.upcase == 'R')) then
   search_town = select_random_town_with_user_input(default_speed = default_speed, town_path_name = default_town_path_name)
elsif ((user_input.upcase == 'RANDOM FILE') or (user_input.upcase == 'RF')) then
   puts("\nSelecting random existing Trove file...")
   existing_trove_file_list = return_existing_trove_file_list(output_path_name = default_output_path_name, also_print = true)
   if (existing_trove_file_list.size == 0) then
      puts("Sorry, no existing Trove files found")
      continue = false
   else
      trove_result_file_name = existing_trove_file_list.sample
      puts("Selected file: #{File.basename(trove_result_file_name)}")
      search_town = return_trove_file_search_town(trove_result_file_name)
   end
else
   search_town = user_input
end

puts("Search town: #{search_town}")

if (continue == true and trove_result_file_name == '') then
   say_something("Ok. I will now see if I can find any newspaper references to a #{search_word} in #{search_town}")
   trove_result_file_name = File.join(default_output_path_name, "trove_result_#{search_town}_#{search_word}.csv".gsub(/\s/,"_"))
   trove_api_results = fetch_trove_search_results(search_town, search_word, my_trove_key)
   puts("\nWriting results to file now...")
   result_count = write_trove_search_results(trove_api_results, trove_result_file_name, search_word, search_town)
   puts(result_count)

   if (result_count == 0) then
      continue = false
      say_something("\nSorry, no tragedy results found for #{search_town}")
   end
end

if (continue == true) then
   result_count = count_trove_search_results_from_csv(trove_result_file_name)
   random_article_range = Array(1..result_count)
   say_something("\nI now have #{result_count} results on file.\nWould you like me to read a few headlines, to get a sense of the tragedies in #{search_town}?", also_print = true, speed = default_speed)
   user_input = get_user_input(prompt_text = "Enter 'n' if not interested, \nEnter 'exit' to cancel entirely, \nEnter any other key to hear a few sample headlines...")
   if (user_input.upcase == 'EXIT') then
      continue = false
   elsif (user_input.upcase == 'ALL') then
      read_trove_headlines(input_trove_file = trove_result_file_name, speed = default_speed)
   elsif (user_input.upcase != 'N') then
      # reads random sample of 5
      random_article_numbers = Array.new(5) { rand(1..result_count) }
      random_article_numbers = random_article_numbers.uniq
      read_trove_headlines(input_trove_file = trove_result_file_name, speed = default_speed, article_numbers = random_article_numbers)
   end
end

if (continue == true) then 
   say_something("\nShall I pick a random tragedy from this place?", also_print = true, speed = default_speed)
   say_something("Or let me know if you would like to pick a specific article.", also_print = true, speed = default_speed)  
end

while (continue == true) do      
   user_input = get_user_input(prompt_text = "\nI will default to a random selection. \nPlease enter 'pick' if you would like to pick. \nEnter 'exit' to cancel.")
   if (user_input.upcase == 'EXIT') then
      continue = false
   elsif (user_input.upcase == 'PICK') then 
      say_something("\nWhich article are you interested in?", also_print = true, speed = default_speed)  
      user_input = get_user_input(prompt_text = "\Please enter article number\nEnter 'exit' to cancel")   
      if (user_input.upcase == 'EXIT') then
         continue = false
      else
         article_numbers = return_int_array_from_string(user_input, divider = ",")   
         if (article_numbers == false) then
            continue = false
         else
            say_something("Ok. Let's see.", also_print = true, speed = default_speed)
            article_number = article_numbers[0]
         end
      end
   else
      article_number = random_article_range.sample
      say_something("Ok. Here is my random tragedy from #{search_town}.", also_print = true, speed = default_speed)
      puts(article_number)
   end
   if (continue == true) then  
      read_trove_results_by_array(input_trove_file = trove_result_file_name, article_numbers = [article_number], speed = default_speed)
      say_something("\n...So, that was a tragedy from #{search_town}", also_print = true, speed = default_speed)   
      say_something("\nWould you like me to get a copy of the whole article for you?", also_print = true, speed = default_speed)                  
      user_input = get_user_input(prompt_text = "\nEnter 'n' for a different tragedy\nEnter 'exit' to cancel\nEnter 'y' to find out more")
      if (user_input.upcase == 'Y') then
         trove_article_id = return_record_from_csv_file(input_file = trove_result_file_name, row_number = article_number + 1, column_number = 9)
         trove_article_result = fetch_trove_newspaper_article(trove_article_id = trove_article_id, trove_key = my_trove_key)
         trove_article_file = write_trove_newspaper_article_to_file(trove_article_result = trove_article_result, trove_article_id = trove_article_id, output_path_name = default_output_path_name)        
         if (trove_article_file != false) then
            puts("\nContent written to file: #{trove_article_file}")
         end
         say_something("Good luck!", also_print = true, speed = default_speed)
         continue = false
      elsif (user_input.upcase == 'EXIT') then      
         continue = false
      end
   end
end

say_something("\nThank you, goodbye.", also_print = true, speed = default_speed)

puts("\nWill update map files before exiting...")
current_result = write_geojson_for_all_csv_files(town_path_name = default_town_path_name, output_path_name = default_output_path_name)
if (current_result != false) then
   puts("\nHave written #{current_result} map objects to your output directory.")
   puts("\nYou may find the map files useful.\nYou can open them in QGIS or in Google Maps.")
else
   puts("\nSorry, encountered error with updating map files.")
end
