require "csv"
require "net/http"
require "date"
require "rbconfig"
load 'tools_for_general_use.rb'

def select_random_town_with_user_input(default_speed, town_path_name)
   # Previously in digital_death_trip main file, moved here August 9th
   # Assists with near-random choice of town from given inputs 
   # (i.e. random but with room for user to choose source, and to refuse individual towns until an ok random selection is made)
   # First offers choice of input data types for the town dictionary from which to make random selection
   # Assigns 'town_dictionary', either from Vicmap or from PTV Stop files, depending on user choice
   # 'town_dictionary' is a hash of unique town names and coordinates
   # If the function handling either VicMap or PTV Stop file dictionaries fails, this function fails
   # It then makes a random selection from the dictionary keys (i.e. town names), and assigns this to 'random_town'
   # Enters a loop that will continue if the user says 'n' to the random selection/s
   # Only returns when either a) user enters 'EXIT', or b) user presses a value other than 'n'
   result = false
   begin
      # NOTE: moved here August 9th; add error handling and neaten
      town_data_types = ['S for all PTV Stop files on file', 'V for VICMAP']
      puts("You have asked for a RANDOM town.")
      say_something("Ok I can do that. Please choose a data source for me to compile town names from.", also_print = true, speed = default_speed)
      instruction_string = "I can search in: "
      town_data_types.each do |data_type|
        instruction_string += "\n\t'" + data_type + "'"
      end
      instruction_string += "\nWhich would you like me to use? I will default to '#{town_data_types[0]}'"
      source_choice = get_user_input(prompt_text = instruction_string)
      if (source_choice.length == 0) then
         source_choice = town_data_types[0]
      end
      say_something("Ok. Please wait while I process this.", also_print = true, speed = default_speed)
      
      town_dictionary = return_chosen_town_dictionary(source_type = source_choice, town_path_name = town_path_name)
      print_town_dictionary(town_dictionary)

      if (town_dictionary.size == 0) then   
         say_something("I'm sorry, I couldn't find any towns, please check and try again.", also_print = true, speed = default_speed)
         return(result)
      else
         say_something("I found #{town_dictionary.size} unique Victorian towns in this data.", also_print = true, speed = default_speed)
         try_again = true
         while (try_again == true) do
            random_town = town_dictionary.keys.sample
            say_something("\nMy random town choice is #{random_town}", also_print = true, speed = default_speed)      
            say_something("What do you think?", also_print = true, speed = default_speed)
            user_input = get_user_input(prompt_text = "Enter 'n' to try again, \nEnter 'exit' to cancel and exit, \nEnter any other key to continue with this town choice...")
            if (user_input.upcase == 'EXIT') then
               return(result)
            elsif (user_input.upcase == 'N') then
               try_again = true
            else
               puts("Ok. Returning #{random_town}")
               return(random_town)
            end
         end
      end
   rescue
      puts("Error encountered in 'select_random_town_with_user_input'...")
      return(result)
   end
end

def return_chosen_town_dictionary(source_choice, town_path_name, min_stop_files = 2)
   result = Hash.new()
   begin
      if (source_choice[0].upcase == 'S') then
         puts("You have instructed me to use PTV STOP FILES...") 
         stop_file_name_list = return_existing_stop_file_name_list(town_path_name = town_path_name)
         if (stop_file_name_list.size < min_stop_files) then
            puts("Fewer than #{min_stop_files} stop files found, will initiate GTFS unzip...")
            unzip_result = unzip_ptv_gtfs_file(town_path_name = town_path_name)
         end
         town_dictionary = return_town_dictionary_from_stop_file_name_list(stop_file_name_list = stop_file_name_list) 
         return(town_dictionary)      
      elsif (source_choice[0].upcase == 'V') then
         puts("You have instructed me to use VICMAP data...")
         town_dictionary = return_town_dictionary_from_vicmap_file(town_path_name = town_path_name)
         return(town_dictionary)      
      else
         puts("Choice not in list, please try again")      
      end      
      return(result)
   rescue
      puts("Error encountered in 'return_town_data', exiting.")
      return(result)
   end
end

def return_town_dictionary_from_both_sources(town_path_name)   
   # NOTE this method needs explanatory header
   town_dictionary = Hash.new()
   begin
      stop_file_name_list = return_existing_stop_file_name_list(town_path_name = town_path_name)
      
      ptv_town_dictionary = return_town_dictionary_from_stop_file_name_list(stop_file_name_list = stop_file_name_list)
      town_dictionary.merge!(ptv_town_dictionary)
      
      vicmap_town_dictionary = return_town_dictionary_from_vicmap_file(town_path_name = town_path_name)
      town_dictionary.merge!(vicmap_town_dictionary)
      
      return(town_dictionary)
   rescue
      puts("Error encountered in 'return_town_dictionary_from_both_sources'...")
      return(town_dictionary)
   end
end

def return_town_dictionary_from_vicmap_file(town_path_name, file_name = 'vic_and_border_locality_list.csv')
   town_dictionary = Hash.new()
   begin
      if (town_path_name == nil) then
         town_path_name = Dir.pwd
      end
      full_file_name = File.join(town_path_name, file_name)
      town_dictionary = return_town_dictionary_from_single_file(file_name = full_file_name, 
         file_type = 'vicmap', 
         town_field_num = 3, 
         lat_field_num = 11, 
         long_field_num = 12, 
         select_field_num = 6, 
         select_field_value = 'VIC')
      return(town_dictionary)
   rescue
      puts("Error encountered in 'return_town_dictionary_from_vicmap_file'...")
      return(town_dictionary)
   end
end

def return_town_dictionary_from_stop_file_name_list(stop_file_name_list)
   # NOTE this method needs an explanation header
   town_dictionary = Hash.new() 
   begin
      stop_file_name_list.each do |stop_file_name|
         puts("Current PTV stop file: #{stop_file_name}")
         current_town_dictionary = return_town_dictionary_from_single_file(stop_file_name = stop_file_name, 
            file_type = 'ptv', 
            town_field_num = 1, 
            lat_field_num = 2, 
            long_field_num = 3)
         if (current_town_dictionary != false) then 
            town_dictionary.merge!(current_town_dictionary)
         end
      end      
      puts("Finished. Town count: #{town_dictionary.size}")
      town_dictionary_sorted = Hash[ town_dictionary.sort_by { |key, val| key } ]
      return(town_dictionary_sorted)
   rescue
      puts("Error encountered in 'return_town_dictionary_from_stop_file_name_list'...")
      return(town_dictionary)
   end
end

def return_town_dictionary_from_single_file(file_name, file_type = 'ptv', town_field_num=1, lat_field_num=2, long_field_num=3, select_field_num=nil, select_field_value=nil)
   # NOTE this method needs greater explanation
   town_dictionary = Hash.new()
   puts("Attempting to make town dictionary from file #{file_name}")
   begin
      csv_contents = CSV.read(file_name)
      csv_contents.shift
      csv_contents.each do |row|
         if (file_type == 'ptv') then
            town_name = extract_town_string_from_ptv_stop_string(row[town_field_num])
         elsif (file_type == 'vicmap') then
            town_name = extract_town_string_from_vicmap_string(row[town_field_num])
         else
            town_name = row[town_field_num]
         end     
         if (select_field_num.nil? == false) then
            if (row[select_field_num] != select_field_value) then
               #puts("Removing #{town_name}, #{row[select_field_num]} != #{select_field_value}")
               town_name = false
            end
         end

         if (town_name != false) then
            town_dictionary[town_name] = [Float(row[lat_field_num]), Float(row[long_field_num])]
         end
      end
      print_town_dictionary(town_dictionary)
      return(town_dictionary)

   rescue
      puts("Encountered error in return_town_dictionary_from_single_file...")
      return(town_dictionary)
   end
end

def extract_town_string_from_ptv_stop_string(input_string, start_divider="(", end_divider=")")  
   result = false
   begin 
      input_string_parts = input_string.split(start_divider)
      if (input_string_parts.size != 2) then
         return(result)
      else
         target_string = input_string_parts[1]
         town_string = target_string.split(end_divider)[0]
         return(town_string)
      end
   rescue
      puts("Encountered error in extract_town_string_from_ptv_stop_string, input #{input_string}, will skip...")
      return(result)
   end
end

def extract_town_string_from_vicmap_string(input_string)
   begin
      output_string = proper_case(input_string.split("(")[0])
      return(output_string)
   rescue
      return(input_string)
   end
end

def print_town_dictionary(town_dictionary)
   begin
      town_dictionary.each do |town_name, coordinates|
         puts("Town: #{town_name}, Coordinates: #{coordinates}")
      end
   rescue
      return
   end
end

def unzip_ptv_gtfs_file(town_path_name, gtfs_file_name='gtfs.zip', path_numbers_to_unzip=[1, 2, 3, 4, 5, 6])
   # This methods handles the unzipping of a GTFS (General Transit Feed) file
   # These files are very particular, but useful for identifying locations of interest
   # GTS files comprise zipped-zipped files, with numbered subdirectories
   # The numbered subdirectories correspond to types of Public Transport services
   # GTFS types 1 to 6 are the 'bigger' types of public transport: trains, coaches, trams, etc.
   # We want to unzip these, to make the 'stops.txt' file in each, available
   # The method organises:
   # a) unzipping the GTFS main file, then 
   # b) unzipping the zipped files within this, but only for the path numbers of interest 
   # It tracks the unzipped sub-paths with the 'unzipped_path_list'
   # There needs to be at least one unzipped-unzipped file, to count as "success"
   # (just unzipping the top-most GTFS file, won't count, as the 'stops.txt' files will still be zipped)
   # If successful, returns list of path numbers
   # If errors encountered, returns false 
   # Also, if there are no unzipped sub-paths, returns false (as this means only the top-most file was unzipped)
   result = false
   begin
      puts("Now unzipping the PTV GTFS file #{gtfs_file_name}")
      puts("Please wait while I process this. It can take some time.")      
    
      gtfs_unzipped_path = unzip_single_file(input_file_name = gtfs_file_name, input_path_name = town_path_name)
      if (gtfs_unzipped_path == false) then
         return(result)
      end

      unzipped_path_list = Array.new

      path_numbers_to_unzip.each do |path_number|      
         target_path = File.join(gtfs_unzipped_path, path_number.to_s)
         puts("Current target path: #{target_path}")
         zip_file_list = Dir.glob("#{target_path}/*.zip")
         zip_file_list.each do |zip_file_name|       
            unzipped_path = unzip_single_file(input_file_name = zip_file_name)      
            if (unzipped_path != false) then
               unzipped_path_list << unzipped_path
            end           
         end                 
      end     
   
      if (unzipped_path_list.size > 1) then
         return(unzipped_path_list)
      else
         return(result)
      end
   rescue
      puts("Error encountered unzipping PTV GTFS file #{File.join(town_path_name, gtfs_file_name)}")
      return(result)
   end
end

def return_existing_stop_file_name_list(town_path_name)
   stop_file_name_list = []
   begin
      stop_file_name_list = return_matching_file_names(input_path = town_path_name, 
         file_extension = "txt", 
         file_pattern = "stops")
      return(stop_file_name_list)
   rescue
      puts("Encountered error in 'return_existing_stop_file_name_list'")
      return(stop_file_name_list)
   end
end