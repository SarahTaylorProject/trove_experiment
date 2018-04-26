load 'tools_for_talking.rb'
load 'tools_for_trove.rb'
load 'tools_for_digital_death_trip.rb'

clear_screen()
my_trove_key = File.read("my_trove.txt")
search_word = 'tragedy'
default_speed = 180
default_output_path = File.join(Dir.pwd, 'output_files')
default_town_path = File.join(Dir.pwd, 'town_lists')

vic_town_list = return_standard_town_list(source_type='PTV', path_name = default_town_path)
if (vic_town_list == false) then
	say_something("I'm sorry, I encountered an error, please check and try again.", also_print = true, speed = default_speed)
	return(false)
elsif (vic_town_list.size == 0) then	
	say_something("I'm sorry, I couldn't find any towns, please check and try again.", also_print = true, speed = default_speed)
	return(false)
else
	say_something("I found #{vic_town_list.length} unique Victorian towns in this list.", also_print = true, speed = default_speed)
	search_town = vic_town_list.sample
	say_something("My random town choice is #{search_town}", also_print = true, speed = default_speed)
end

output_file_name = File.join(default_output_path, "trove_result_#{search_town}_#{search_word}.csv".gsub(/\s/,"_"))
puts(output_file_name)
trove_api_results = fetch_trove_results(search_town, search_word, my_trove_key)
puts(trove_api_results)
puts("\nWriting results to file now...")
result_count = write_trove_results(trove_api_results, output_file_name, search_word, search_town)
puts(result_count)

if (result_count > 0) then
   preview_trove_results(output_file_name)
   read_trove_results(input_trove_file = output_file_name, read_all = true, max_articles = 6)
else
	say_something("I'm sorry, no results found for this town, please try again.")
end