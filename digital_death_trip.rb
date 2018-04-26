load 'tools_for_talking.rb'
load 'tools_for_trove.rb'
load 'tools_for_digital_death_trip.rb'

clear_screen()
my_trove_key = File.read("my_trove.txt")
search_word = 'tragedy'
default_speed = 180
default_output_path = File.join(Dir.pwd, 'output_files')
default_town_path = File.join(Dir.pwd, 'town_lists')
max_articles_to_read = 5
standard_town_data_types = ['PTV', 'VICMAP', 'SAMPLE PTV STOP FILE']

say_something("Hello, this is Digital Death Trip in test mode.", also_print = true, speed = default_speed)
say_something("Today I am talking to you from a #{operating_system()} operating system.", also_print = true, speed = default_speed)

instruction_string = "Please choose a data source for me to gather town names from."
say_something(instruction_string, also_print = false, speed = default_speed)
instruction_string += "\nI can search in: "
standard_town_data_types.each do |data_type|
  instruction_string += "\n\t'" + data_type + "'"
end
instruction_string += "\nWhich would you like me to use? I will default to #{standard_town_data_types[0]}"
source_choice = get_user_input(prompt_text = instruction_string)
puts(source_choice.length)
if (source_choice.length == 0) then
	source_choice = standard_town_data_types[0]
end
say_something("You have instructed me to use #{source_choice} data to compile a list of town names.", also_print = true, speed = default_speed)
say_something("Please wait while I process this. It can take some time.", also_print = true, speed = default_speed)

vic_town_list = return_standard_town_list(source_type=source_choice, path_name = default_town_path)
if (vic_town_list == false) then
	say_something("I'm sorry, I encountered an error, please check and try again.", also_print = true, speed = default_speed)
	return(false)
elsif (vic_town_list.size == 0) then	
	say_something("I'm sorry, I couldn't find any towns, please check and try again.", also_print = true, speed = default_speed)
	return(false)
else
	say_something("I found #{vic_town_list.length} unique Victorian towns in this data.", also_print = true, speed = default_speed)
	search_town = vic_town_list.sample
	say_something("My random town choice is #{search_town}", also_print = true, speed = default_speed)
	say_something("I will now see if I can find any newspaper references to a #{search_word} in #{search_town}")
end

output_file_name = File.join(default_output_path, "trove_result_#{search_town}_#{search_word}.csv".gsub(/\s/,"_"))
puts(output_file_name)
trove_api_results = fetch_trove_results(search_town, search_word, my_trove_key)
puts(trove_api_results)
puts("\nWriting results to file now...")
result_count = write_trove_results(trove_api_results, output_file_name, search_word, search_town)
puts(result_count)

if (result_count > 0) then
	say_something("I am previewing the results for you on the screen.")
   preview_trove_results(output_file_name)
   say_something("I will now read previews of #{max_articles_to_read}some articles.")
   read_trove_results(input_trove_file = output_file_name, read_all = true, max_articles = max_articles_to_read)
else
	say_something("I'm sorry, no results found for this town, please try again.")
end