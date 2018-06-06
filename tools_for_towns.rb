require "csv"
require "net/http"
require "date"
require "rbconfig"
load 'tools_for_general_use.rb'


class Town_data_option
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


def return_town_data_options
   town_data_source_dictionary = {}
   town_data_source_dictionary['1'] = Town_data_option.new('Stop files', "(will use all stops.txt files found in directory)", method(:return_town_coordinate_dictionary_from_multiple_ptv_stop_files))
   town_data_source_dictionary['2'] = Town_data_option.new('PTV GTFS zip file', "(only needed if the GTFS file has not been unzipped)", method(:return_town_coordinate_dictionary_from_gtfs_file))
   town_data_source_dictionary['3'] = Town_data_option.new('VicMap', "(will use the VicMap Locality CSV file in directory)", method(:return_town_coordinate_dictionary_from_vicmap_file))
   return(town_data_source_dictionary)
end


def print_town_data_options(town_data_options)
   puts("\n")
   town_data_options.each do |key, value|
      puts("#{key}: #{value.source_name} #{value.source_description}\n")
   end
end


def return_chosen_town_list_and_town_coordinate_dictionary(source_choice, town_data_options, town_path_name=File.join(Dir.pwd, 'town_lists'))
   result = false
   begin
      if not (town_data_options.keys.include? source_choice) then
         puts("Choice not available, exiting...")
         return(result)
      end
      source_choice_details = town_data_options[source_choice]
      puts("You have instructed me to use: #{source_choice_details.source_name}")
      puts(source_choice_details.source_function)
      town_coordinate_dictionary = source_choice_details.source_function.call(town_path_name)
      if (town_coordinate_dictionary != false) then
         town_list = return_town_list_from_town_coordinate_dictionary(town_coordinate_dictionary)
      end
      return([town_list, town_coordinate_dictionary])
   rescue
      puts("Error encountered, exiting.")
      return(result)
   end
end


def return_hybrid_town_coordinate_dictionary(input_path_name)
   town_coordinate_dictionary = {}
   ptv_town_coordinate_dictionary = return_town_coordinate_dictionary_from_multiple_ptv_stop_files(path_name = input_path_name)
   if (ptv_town_coordinate_dictionary != false) then
      town_coordinate_dictionary.merge!(ptv_town_coordinate_dictionary)
   end
   vicmap_town_coordinate_dictionary = return_town_coordinate_dictionary_from_vicmap_file(input_path_name = input_path_name)
   if (vicmap_town_coordinate_dictionary != false) then
      town_coordinate_dictionary.merge!(vicmap_town_coordinate_dictionary)
   end
   return(town_coordinate_dictionary)
end


def return_town_coordinate_dictionary_from_vicmap_file(input_path_name, file_name = 'vic_and_border_locality_list.csv')
   result = false
   begin
      if (input_path_name == nil) then
         input_path_name = Dir.pwd
      end
      full_file_name = File.join(input_path_name, file_name)
      town_coordinate_dictionary = return_town_coordinate_dictionary_from_single_file(file_name = full_file_name, file_type = 'vicmap', town_field_num = 3, lat_field_num = 11, long_field_num = 12, select_field_num = 6, select_field_value = 'VIC')
   rescue
      puts("Error encountered in return_town_coordinate_dictionary_from_vicmap...")
      return(result)
   end
end


def return_town_coordinate_dictionary_from_multiple_ptv_stop_files(input_path_name, default_stop_file_name='stops.txt', town_field_num=1, lat_field_num=2, long_field_num=3)
   result = false
   begin
      town_coordinate_dictionary = Hash.new() 

      stop_file_list = Dir.glob("#{input_path_name}/**/#{default_stop_file_name}")
      stop_file_list.each do |stop_file_name|
         puts("PTV stop file: #{stop_file_name}")
         current_town_coordinate_dictionary = return_town_coordinate_dictionary_from_single_file(stop_file_name = stop_file_name, file_type = 'ptv', town_field_num = town_field_num, lat_field_num = lat_field_num, long_field_num = long_field_num)
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
      puts("Error encountered in return_town_coordinate_dictionary_from_multiple_ptv_stop_files...")
      return(result)
   end
end


def return_town_coordinate_dictionary_from_single_file(file_name, file_type = 'ptv', town_field_num=1, lat_field_num=2, long_field_num=3, select_field_num=nil, select_field_value=nil)
   result = false
   puts("Attempting to make town dictionary from file #{file_name}")
   begin
      csv_contents = CSV.read(file_name)
      csv_contents.shift
      town_coordinate_dictionary = Hash.new()
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
      return(result)
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


def return_town_coordinate_dictionary_from_gtfs_file(input_path_name, gtfs_file_name='gtfs.zip', path_numbers_to_unzip=[1, 2, 3, 4, 5, 6])
   result = false
   begin
      puts("return_town_coordinates_from_gtfs_file")
      unzip_result = unzip_ptv_gtfs_file(input_path_name = input_path_name)
      if (unzip_result == true) then
         town_coordinate_dictionary = return_town_coordinate_dictionary_from_multiple_ptv_stop_files(path_name = input_path_name)
         return(town_coordinate_dictionary)
      end
      return(result)
   rescue
      puts("Error encountered...")
      return(result)
   end
end


def unzip_ptv_gtfs_file(input_path_name, gtfs_file_name='gtfs.zip', path_numbers_to_unzip=[1, 2, 3, 4, 5, 6])
   # unzipping the gtfs format file: very particular, they are zipped-zipped files, with numbered subdirectories
   # returns true if successful in unzipping the main file and at least one zipped file from within this
   # returns false if errors enountered and/or no zipped file from within the initial zip file, is successfully unzipped
   result = false
   begin
      puts("Now unzipping the PTV GTFS file #{gtfs_file_name}")
      puts("Please wait while I process this. It can take some time.")
      unzipped_path_list = Array.new
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
         
         if (unzipped_path_list.size > 1) then
            result = true
         end
      
      end#of path_numbers_to_unzip.each
      return(result)
   rescue
      puts("Error encountered unzipping PTV GTFS file #{File.join(input_path_name, gtfs_file_name)}")
      return(result)
   end
end
