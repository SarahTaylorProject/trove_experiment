require "csv"
require "net/http"
require "date"
require "rbconfig"

def return_town_list_from_vicmap(search_state='VIC', vicmap_csv_file_name='vic_and_border_locality_list.csv', town_field_num=5, state_field_num=6)
	result = []
	puts("Attempting to read VicMap town list from #{vicmap_csv_file_name}")
	begin
		csv_contents = CSV.read(vicmap_csv_file_name)
		csv_contents.shift
		town_list_from_csv = csv_contents.map { |row|
			[row[town_field_num], row[state_field_num]]
		}.uniq
		full_town_list = town_list_from_csv.select { |town, state|
			state == search_state
		}
		town_list = full_town_list.map { |row| row[0] }
		puts(town_list)
		return(town_list)

	rescue
		return(result)
	end

end

#field_array = [stop_id,stop_name,stop_lat,stop_lon]
def return_town_list_from_ptv_stops(ptv_stop_file_name='stops.txt', stop_name_field_num=1)
	result = []
	puts("Attempting to make town list from PTV stops file #{ptv_stop_file_name}")
	begin
		csv_contents = CSV.read(ptv_stop_file_name)
		csv_contents.shift
		
		stop_list_from_csv = csv_contents.map { |row|
			row[stop_name_field_num]
		}.uniq
		#puts(stop_list_from_csv)
		
		full_town_list = stop_list_from_csv.map { |stop_string|
	 		pull_town_string_from_ptv_stop_string(stop_string)
		}
	   # puts(full_town_list)
	   # puts(full_town_list.size)

	   town_list = full_town_list.select { |town|
			town != false
		}
		puts(town_list)
		puts(town_list.size)
		return(town_list)

	rescue
		return(result)
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


def remove_unfinished_sentence(input_string, divider = ".")
   # This method removes any unfinished sentence from a string
   begin
   	if (input_string[-1] == divider) then
      	return(input_string)
   	end

   	output_string = ''
   	input_sentence_array = input_string.split(divider)

   	if (input_sentence_array.size == 1) then
      	return(input_string)
   	end

   	for sentence in input_sentence_array[0..-2].each do
      	output_string += sentence + divider      
   	end

   	return(output_string)
   rescue
   	puts("Error encountered, will return input string.")
   	return(input_string)
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