load 'tools_for_talking.rb'
load 'tools_for_trove.rb'

clear_screen()
my_trove_key = File.read("my_trove.txt")
search_word = 'tragedy'
default_speed = 180

test_offline_only = true
test_csv_file = 'trove_result_BULGANA_tragedy.csv'

continue = true

say_something("Hello, I am in test mode. Today I am in a #{operating_system()} operating system.")

if (test_offline_only == false) then
	town_list_from_csv = CSV.read('vic_and_border_locality_list.csv').map { |row|
		[row[5], row[6]]
	}.uniq
	vic_town_list = town_list_from_csv.select { |town, state|
		state == 'VIC'
	}
	say_something("There are #{vic_town_list.length} Victorian towns in my list.", also_print = true, speed = default_speed)
	search_town = vic_town_list.sample[0]
	say_something("My random town choice is #{search_town}", also_print = true, speed = default_speed)
	output_file_name = "trove_result_#{search_town}_#{search_word}.csv".gsub(/\s/,"_")
	trove_api_results = fetch_trove_results(search_town, search_word, my_trove_key)
	puts(trove_api_results)
	puts("\nWriting results to file now...")
	result_count = write_trove_results(trove_api_results, output_file_name, search_word, search_town)
	puts(result_count)
else
	output_file_name = test_csv_file
end

preview_trove_results(output_file_name)

if (continue == true) then
   say_instruction "\n\nPreviewing results."
   preview_trove_results(output_file_name)
   read_trove_results(input_trove_file = output_file_name, read_all = true, max_articles = 6)
end