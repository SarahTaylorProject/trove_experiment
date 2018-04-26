require "csv"
require "net/http"
require "date"
require "rbconfig"

def return_town_list_from_vicmap(search_state='VIC', vicmap_csv_file_name='vic_and_border_locality_list.csv', town_field_num=5, state_field_num=6)
	result = []
	puts("Attempting to read VicMap town list from #{vicmap_csv_file_name}")
	begin
		town_list_from_csv = CSV.read(vicmap_csv_file_name).map { |row|
			[row[town_field_num], row[state_field_num]]
		}.uniq
		town_list = town_list_from_csv.select { |town, state|
			state == search_state
		}
		puts(town_list)
	rescue
		return(result)
	end

	return(town_list)

end


def remove_unfinished_sentence(input_string, divider = ".")
   # This method removes any unfinished sentence from a string

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