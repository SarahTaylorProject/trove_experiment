require "csv"
require "net/http"
require "date"
require "rbconfig"
load 'tools_for_general_use.rb'

def return_town_data(source_choice, town_path_name, min_stop_files = 2)
   result = false
   begin
      if (source_choice[0].upcase == 'S') then
         puts("You have instructed me to use the existing PTV STOP FILES...") 
         stop_file_name_list = return_existing_stop_file_name_list(town_path_name = town_path_name)
         if (existing_stop_file_name_list.size < min_stop_files) then
            puts("Fewer than 2 stop files found...")
            unzip_result = unzip_ptv_gtfs_file(town_path_name = town_path_name)
            if (unzip_result == false) then
               puts("Unzip result: #{unzip_result}")
               return(result)
            end
         end
         town_coordinate_dictionary = return_town_coordinate_dictionary_from_stop_file_name_list(stop_file_name_list = stop_file_name_list) 
         town_list = return_town_list_from_town_coordinate_dictionary(town_coordinate_dictionary)
         return([town_list, town_coordinate_dictionary])
      elsif (source_choice[0].upcase == 'V') then
         puts("You have instructed me to use VICMAP data to compile a list of town names.")
         town_coordinate_dictionary = return_town_coordinate_dictionary_from_vicmap_file(town_path_name = town_path_name)
         town_list = return_town_list_from_town_coordinate_dictionary(town_coordinate_dictionary)
         return([town_list, town_coordinate_dictionary])
      else
         puts("Choice not in list, please try again")
      end
      return(result)
   rescue
      puts("Error encountered in 'return_town_data', exiting.")
      return(result)
   end
end


def return_town_coordinate_dictionary(town_path_name)
   ##NOTE these function should be made to use the stops file search; plus need to add error handling here
   stop_file_name_list = return_existing_stop_file_name_list(town_path_name = town_path_name)
   town_coordinate_dictionary = return_town_coordinate_dictionary_from_stop_file_name_list(stop_file_name_list = stop_file_name_list)
   vicmap_town_coordinate_dictionary = return_town_coordinate_dictionary_from_vicmap_file(town_path_name = town_path_name)
   town_coordinate_dictionary.merge!(vicmap_town_coordinate_dictionary)
   return(town_coordinate_dictionary)
end


def return_town_coordinate_dictionary_from_vicmap_file(town_path_name, file_name = 'vic_and_border_locality_list.csv')
   result = false
   begin
      if (town_path_name == nil) then
         town_path_name = Dir.pwd
      end
      full_file_name = File.join(town_path_name, file_name)
      town_coordinate_dictionary = return_town_coordinate_dictionary_from_single_file(file_name = full_file_name, 
         file_type = 'vicmap', 
         town_field_num = 3, 
         lat_field_num = 11, 
         long_field_num = 12, 
         select_field_num = 6, 
         select_field_value = 'VIC')
   rescue
      puts("Error encountered in 'return_town_coordinate_dictionary_from_vicmap_file'...")
      return(result)
   end
end

def return_town_coordinate_dictionary_from_stop_file_name_list(stop_file_name_list)
#def return_town_coordinate_dictionary_from_stop_file_name_list(unzipped_path_list, default_stop_file_name='stops.txt', town_field_num=1, lat_field_num=2, long_field_num=3)
   town_coordinate_dictionary = Hash.new() 
   begin
      ##NOTE: swapped here, and should return empty hash if error encountered
      stop_file_name_list.each do |stop_file_name|
         puts("PTV stop file: #{stop_file_name}")
         current_town_coordinate_dictionary = return_town_coordinate_dictionary_from_single_file(stop_file_name = stop_file_name, 
            file_type = 'ptv', 
            town_field_num = 1, 
            lat_field_num = 2, 
            long_field_num = 3)
         if (current_town_coordinate_dictionary != false) then 
            puts("Adding #{current_town_coordinate_dictionary.size} town references to dictionary.")
            town_coordinate_dictionary.merge!(current_town_coordinate_dictionary)
         end
         puts("Working through PTV list. Current unsorted town references: #{town_coordinate_dictionary.size}")
      end      
      puts("Finished searching for town references.")
      puts("Town count: #{town_coordinate_dictionary.size}")
      town_coordinate_dictionary_sorted = Hash[ town_coordinate_dictionary.sort_by { |key, val| key } ]
      return(town_coordinate_dictionary_sorted)
   rescue
      puts("Error encountered in 'return_town_coordinate_dictionary_from_stop_file_name_list'...")
      return(town_coordinate_dictionary)
   end
end


def return_town_coordinate_dictionary_from_single_file(file_name, file_type = 'ptv', town_field_num=1, lat_field_num=2, long_field_num=3, select_field_num=nil, select_field_value=nil)
##NOTE need to examine/document this function again
   town_coordinate_dictionary = Hash.new()
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
            town_coordinate_dictionary[town_name] = [Float(row[lat_field_num]), Float(row[long_field_num])]
         end
      end
      print_town_coordinate_dictionary(town_coordinate_dictionary)
      return(town_coordinate_dictionary)

   rescue
      puts("Encountered error in return_town_coordinate_dictionary_from_single_file...")
      return(town_coordinate_dictionary)
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


def return_town_list_from_town_coordinate_dictionary(town_coordinate_dictionary)
   result = false
   begin
      town_list = town_coordinate_dictionary.map { |town, coordinates|
         town
      }
   rescue
      puts("Encountered error in return_town_list_from_town_coordinate_dictionary...")
      return(result)
   end
end


def print_town_coordinate_dictionary(town_coordinate_dictionary)
   begin
      town_coordinate_dictionary.each do |town_name, coordinates|
         puts("Town: #{town_name}, Coordinates: #{coordinates}")
      end
   rescue
      return
   end
end


def unzip_ptv_gtfs_file(input_path_name, gtfs_file_name='gtfs.zip', path_numbers_to_unzip=[1, 2, 3, 4, 5, 6])
   # unzipping the gtfs format file: very particular, they are zipped-zipped files, with numbered subdirectories
   # returns true if successful in unzipping the main file and at least one zipped file from within this
   # returns false if errors enountered and/or no zipped file from within the initial zip file, is successfully unzipped
   result = false
   begin
      # NOTE: CHECK IF UNZIPPED FILES HERE FIRST
      puts("Now unzipping the PTV GTFS file #{gtfs_file_name}")
      puts("Please wait while I process this. It can take some time.")
      #unzipped_path_list = Array.new
      gtfs_unzipped_path = unzip_single_file(input_file_name = gtfs_file_name, input_path_name = input_path_name)
      if (gtfs_unzipped_path == false) then
         return(result)
      end
      # unzip the zip files that came out of the initial unzip, but only for the specified path numbers
      path_numbers_to_unzip.each do |path_number|      
         target_path = File.join(gtfs_unzipped_path, path_number.to_s)
         puts("Current target path: #{target_path}")
         zip_file_list = Dir.glob("#{target_path}/*.zip")
         puts(zip_file_list)
         zip_file_list.each do |zip_file_name|       
            unzipped_path = unzip_single_file(input_file_name = zip_file_name)      
            if (unzipped_path != false) then
               unzipped_path_list << unzipped_path
            end                    
         end# of zip_file_list.each               
         puts(unzipped_path_list)
      
      end#of path_numbers_to_unzip.each     
      if (unzipped_path_list.size > 1) then
         return(unzipped_path_list)
      else
         return(result)
      end
   rescue
      puts("Error encountered unzipping PTV GTFS file #{File.join(input_path_name, gtfs_file_name)}")
      return(result)
   end
end


def return_existing_stop_file_name_list(town_path_name)
   stop_file_list = []
   begin
      stop_file_list = return_matching_file_names(input_path = town_path_name, 
         file_extension = "txt", 
         file_pattern = "stops")
      return(stop_file_list)
   rescue
      puts("Encountered error in 'return_existing_stop_file_name_list'")
      return(stop_file_list)
   end
end