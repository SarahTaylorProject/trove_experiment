
class Town_data_source
   attr_accessor :source_name, :source_description, :source_function
   def initialize(source_name, source_description, source_function=nil)
      @source_name = source_name
      @source_description = source_description
      @source_function = source_function
   end
   def display
      puts("#{@source_name}: #{@source_description}\n")
   end
end


def return_town_data_source_dictionary
   town_data_source_dictionary = {}
   town_data_source_dictionary['1'] = Town_data_source.new('Stop files', "All PTV stop files already on file", method(:return_town_coordinate_dictionary_from_multiple_ptv_stop_files))
   town_data_source_dictionary['2'] = Town_data_source.new('GTFS zip', "PTV GTFS zip file (only necessary if the GTFS file has not been unzipped)", method(:return_town_coordinate_dictionary_from_gtfs_file))
   town_data_source_dictionary['3'] = Town_data_source.new('VicMap', "VicMap Locality CSV file", method(:return_town_coordinate_dictionary_from_vicmap_file))
   return(town_data_source_dictionary)
end


def return_town_data(source_choice, town_data_source_dictionary, input_path_name=File.join(Dir.pwd, 'town_lists'))
   result = false
   begin
      if not (town_data_source_dictionary.keys.include? source_choice) then
         puts("Choice not available, exiting...")
         return(result)
      end
      source_choice_full = town_data_source_dictionary[source_choice]
      puts("You have instructed me to use: #{source_choice_full.source_name}")
      puts(source_choice_full.source_function)
      town_list = source_choice_full.source_function.call(input_path_name)
      result = town_list

      return(result)
   rescue
      puts("Error encountered, exiting.")
      return(result)
   end
end

def return_town_coordinate_dictionary_from_vicmap_file(input_path_name, file_name = 'vic_and_border_locality_list.csv')
   puts("PLACEHOLDER FOR VICMAP METHOD")
   return(true)
end

def return_town_coordinate_dictionary_from_multiple_ptv_stop_files(input_path_name, default_stop_file_name='stops.txt', town_field_num=1, lat_field_num=2, long_field_num=3)
   puts("PLACEHOLDER FOR MULTIPLE STOP FILES METHOD")
   return(true)
end

def return_town_coordinate_dictionary_from_gtfs_file(input_path_name, gtfs_file_name='gtfs.zip', path_numbers_to_unzip=[1, 2, 3, 4, 5, 6])
   result = false
   begin
      puts("return_town_coordinates_from_gtfs_file")
      unzip_result = unzip_ptv_gtfs_file(input_path_name = input_path_name)
      if (unzip_result == true) then
         town_coordinate_dictionary = return_town_coordinate_dictionary_from_multiple_ptv_stop_files(path_name = input_path_name)
         town_list = return_town_list_from_town_coordinate_dictionary(town_coordinate_dictionary)
         return([town_list, town_coordinate_dictionary])
      end
      return(result)
   rescue
      puts("Error encountered...")
      return(result)
end

def get_user_input(prompt_text = "\nPlease enter value")
   # This method just gets direct input from the user with a prompt
   # Returns the user input
   # Nothing fancy, just a handy function

   if (prompt_text.length > 0) then
      puts(prompt_text) 
   end
   input_text = STDIN.gets.chomp
   return(input_text)

end


### MAIN
continue = true
user_input = get_user_input(prompt_text = "Enter town name OR 'random'\nEnter 'exit' to cancel")


if (user_input.upcase == 'EXIT') then
   continue = false
end


if (continue == true and user_input.upcase == 'RANDOM') then
   town_data_source_dictionary = return_town_data_source_dictionary()
   #puts(town_data_source_dictionary)

   town_data_source_dictionary.each do |key, value|
      puts("#{key}: #{value}\n")
   end
   source_choice = get_user_input()
   puts(source_choice)

   result = return_town_data(source_choice = source_choice, town_data_source_dictionary = town_data_source_dictionary)

end
