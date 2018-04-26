require "csv"
require "net/http"
require "date"
require "rbconfig"
load 'tools_for_talking.rb'

def return_standard_town_list(source_type, path_name)
	case source_type.upcase
		when 'PTV'						
			town_list = return_town_list_from_zipped_ptv_stop_files(main_path_name = path_name)
			return(town_list)
		when 'VICMAP'
			town_list = return_town_list_from_vicmap(path_name = path_name)
			return(town_list)
		when 'SAMPLE PTV STOP FILE'
			town_list = return_town_list_from_single_ptv_stop_file(path_name = path_name)
			return(town_list)
		else
			puts("Choice not in standard lists, please try again")
			return(false)
		end
end


def return_town_list_from_vicmap(path_name=Dir.pwd, search_state='VIC', vicmap_csv_file_name='vic_and_border_locality_list.csv', town_field_num=5, state_field_num=6)
	result = []
	puts("Attempting to read VicMap town list from #{File.join(path_name, vicmap_csv_file_name)}")
	begin		
		full_file_name = File.join(path_name, vicmap_csv_file_name)
		csv_contents = CSV.read(full_file_name)
		csv_contents.shift
		town_list_from_csv = csv_contents.map { |row|
			[row[town_field_num], row[state_field_num]]
		}.uniq
		full_town_list = town_list_from_csv.select { |town, state|
			state == search_state
		}
		puts(full_town_list)
		town_list = full_town_list.map { |town, state|
			town
		}.uniq
		puts(town_list)
		return(town_list)

	rescue
		return(result)
	end

end


def return_town_list_from_zipped_ptv_stop_files(main_path_name=Dir.pwd, main_file_name='gtfs.zip', stop_file_name='stops.txt', stop_field_num=1)
	result = false
	begin
		full_town_list = Array.new	
		unzipped_path_list = unzip_ptv_file_and_return_path_list(main_file_name = main_file_name, main_path_name = main_path_name)
		unzipped_path_list.each do |path_name|
			puts(path_name)
			puts(stop_file_name)
			puts(stop_field_num)
			current_town_list = return_town_list_from_single_ptv_stop_file(path_name = path_name, stop_file_name = stop_file_name, stop_field_num = stop_field_num)
			puts("PTV stop file: #{File.join(path_name, stop_file_name)}")
			puts("Adding #{current_town_list.size} town references to unsorted town list.")
			full_town_list.concat current_town_list
			say_something("Working through PTV list. Current unsorted town references: #{full_town_list.size}")
		end		
		town_list = full_town_list.sort.uniq
		say_something("Finished searching for town references in zipped files.")
		puts("Sorted town count: #{town_list.size}")
		return(town_list)
	rescue
		puts("Error encountered extracting towns from zipped PTV file #{File.join(main_path_name, main_file_name)}")
		return(result)
	end
end


def return_town_list_from_single_ptv_stop_file(path_name=Dir.pwd, stop_file_name='stops.txt', stop_field_num=1)
	result = []
	puts("Attempting to make town list from PTV stop file #{File.join(path_name, stop_file_name)}")
	begin
		full_file_name = File.join(path_name, stop_file_name)
		csv_contents = CSV.read(full_file_name)
		csv_contents.shift
		
		stop_list_from_csv = csv_contents.map { |row|
			row[stop_field_num]
		}.uniq
		
		full_town_list = stop_list_from_csv.map { |stop_string|
	 		pull_town_string_from_ptv_stop_string(stop_string)
		}

	   town_list = full_town_list.select { |town|
			town != false
		}
		puts(town_list.size)
		return(town_list)

	rescue
		return(result)
	end

end


def unzip_ptv_file_and_return_path_list(main_file_name='gtfs.zip', main_path_name=Dir.pwd, path_numbers_to_unzip=[1, 2, 3, 4, 5, 6])
	say_something("I am now unzipping the PTV files.")
	unzipped_path_list = Array.new
	main_unzipped_path = unzip_single_file(file_name = main_file_name, path_name = main_path_name)
	if (main_unzipped_path != false) then
		for path_number in path_numbers_to_unzip.each do
			target_path = File.join(main_unzipped_path, path_number.to_s)
			puts("Current target path: #{target_path}")
			Dir.foreach(target_path) do |file_name|
				if (file_name.include?(".zip")) then
					puts("Will try to unzip #{File.join(target_path, file_name)}")					
					unzipped_path = unzip_single_file(file_name = file_name, path_name = target_path)		
					if (unzipped_path != false) then
						unzipped_path_list << unzipped_path
					end
				end		
			end
		end		
		puts(unzipped_path_list)
		return(unzipped_path_list)
	else
		puts("Error encountered unzipping PTV file #{File.join(main_path_name, main_file_name)}")
		return(unzipped_path_list)
	end

end


def unzip_single_file(file_name, path_name=Dir.pwd, overwrite = true, output_path_name=nil)
	# unzips a single zip file
	# most code borrowed from https://gist.github.com/robc/217400
	# returns the output path if successful, or false if error encountered
	# if output_path_name is left as nil then it will construct a default output location using zip file norms
	begin
		full_file_name = File.join(path_name, file_name)
		if (output_path_name == nil) then
			output_path_name = File.join(path_name, File.basename(file_name, '.zip'))
		end
		command_string = "unzip "
		if (overwrite == true) then
			command_string += "-o "
		end
		command_string += full_file_name + " -d " + output_path_name
		puts(command_string)
		system(command_string)
		puts("Successfully unzipped #{full_file_name}")
		return(output_path_name)
	rescue	
		puts("Error encountered with unzipping #{file_name}")	
		return(false)
	end

end


def pull_town_string_from_ptv_stop_string(input_string, start_divider="(", end_divider=")")  
	result = false
	begin 
		input_string_parts = input_string.split(start_divider)

		if (input_string_parts.size != 2) then
			puts("String format for #{input_string} does not match PTV stop names, will return false.")
			return(result)
		else
			target_string = input_string_parts[1]
			town_string = target_string.split(end_divider)[0]
			puts(town_string)
			return(town_string)
		end
	rescue
		puts("Error encountered extracting town from #{input_string}, will return false.")
		return(result)
	end

end


def convert_phrase_string_for_url(input_string, input_divider = ' ', output_quotemark='%22', output_divider='%20')
   # changes a phrase string with spaces, to string suitable for use in a URL
   # treats as a single phrase, not as separate words
   # (i.e. puts a URL-friendly quote symbol at the start and end, and URL-friendly dividers in the middle)
   # https://www.w3schools.com/tags/ref_urlencode.asp
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

end