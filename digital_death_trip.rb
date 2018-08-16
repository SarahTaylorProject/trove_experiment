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
#standard_town_data_types = ['S or P for PTV Stop Files', 'V for VICMAP']
#standard_town_data_types = ['S or P for all existing PTV Stop files', 'G to unzip PTV GTFS zip file', 'V for VICMAP']
continue = true

# START TESTING AREA
# 1 test existing file list
existing_trove_result_file_list = return_existing_trove_result_file_list(output_path_name = default_output_path_name)

# 2 test geojson files
# current_result = write_geojson_for_all_csv_files(town_path_name = default_town_path_name, 
#    output_path_name = default_output_path_name)

# 3 test random town selection
# search_town = select_random_town_with_user_input(default_speed, town_path_name = default_town_path_name)
# puts(search_town)

puts("Files already available: #{existing_trove_result_file_list.size}")
existing_trove_result_file_list.each do |file_name|
   search_town = return_trove_file_search_town(file_name)
   search_word = return_trove_file_search_word(file_name)
   result_count = count_trove_search_results_from_csv(file_name)
   puts("#{File.basename(file_name)} (#{search_word}, #{search_town}, #{result_count} results)")
end
puts("Trove result files already available: #{existing_trove_result_file_list.size}")

exit()
###
say_something("Hello, this is Digital Death Trip.", also_print = true, speed = default_speed)
say_something("Today I am talking to you from a #{operating_system()} operating system.", also_print = true, speed = default_speed)

say_something("\nWould you like to choose a town, or would you like me to make a random selection?", also_print = true, speed = default_speed)
user_input = get_user_input(prompt_text = "Enter town name OR 'random'\nEnter 'exit' to cancel")

if (user_input.upcase == 'EXIT') then
   continue = false
elsif ((user_input.upcase == 'RANDOM') or (user_input.upcase == 'R')) then
   search_town = select_random_town_with_user_input(default_speed = default_speed, town_path_name = default_town_path_name)
else
   search_town = user_input
end

puts("Search town is #{search_town}")

# TEST EXIT
exit()
# nb. need function here to gather coordinates for town choices not made through town_dictionary
# START PASTE

 if (continue == true) then
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
# search_town = 'Elmore'
output_file_name = File.join(default_output_path_name, "trove_result_#{search_town}_#{search_word}.csv".gsub(/\s/,"_"))

if (continue == true) then
   result_count = preview_trove_search_results_from_csv(output_file_name)
   say_something("\nI found some results.\nWould you like me to read a few headlines, to get a sense of the tragedies in #{search_town}?", also_print = true, speed = default_speed)
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

while (continue == true) do   
   clear_screen()
   result_count = preview_trove_search_results_from_csv(output_file_name)
   
   say_something("\nShall I pick a random tragedy from this place? Or let me know if you would like to pick from some specific articles", also_print = true, speed = default_speed)  
   user_input = get_user_input(prompt_text = "\nI will default to a random selection. \nPlease enter 'pick' if you would like to pick. \nEnter 'n' or exit' to cancel.")
   if (user_input.upcase == 'N' or user_input.upcase == 'EXIT') then
      continue = false
   elsif (user_input.upcase == 'PICK') then 
      say_something("\nWhich articles are you interested in?", also_print = true, speed = default_speed)  
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
         say_something("Ok. I will read articles #{article_numbers}", also_print = true, speed = default_speed)
         read_trove_results_by_array(input_trove_file = output_file_name, article_numbers = article_numbers, speed = default_speed)
      end

   else
      random_article_number = random_article_range.sample
      say_something("Ok. Here is my random tragedy from #{search_town}.", also_print = true, speed = default_speed)
      read_trove_results_by_array(input_trove_file = output_file_name, article_numbers = [random_article_number], speed = default_speed)
   end               
end

# END PASTE

say_something("\nThank you, goodbye.", also_print = true, speed = default_speed)

puts("\nWill update map files before exiting...")
current_result = write_geojson_for_all_csv_files(town_path_name = default_town_path_name, default_output_path_name = default_output_path_name, write_individual_files = true)
if (current_result != false) then
   puts("\nHave written #{current_result} map objects to your output directory.")
   puts("\nYou may find the map files useful.\nYou can open them in QGIS or in Google Maps.")
else
   puts("\nSorry, encountered error with updating map files.")
end
