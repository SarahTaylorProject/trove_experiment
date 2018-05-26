require "csv"
require "net/http"
require "date"
require "rbconfig"
load 'tools_for_general_use.rb'

def return_town_data(source_choice, input_path_name)
   result = false
   begin
      if (source_choice[0].upcase == 'S') then
         puts("You have instructed me to use the existing PTV STOP FILES to compile a list of town names.") 
         town_dictionary = return_town_dictionary_from_multiple_ptv_stop_files(path_name = input_path_name)
         town_list = return_town_list_from_town_dictionary(town_dictionary)
         return([town_list, town_dictionary])
      elsif (source_choice[0].upcase == 'P') then
         puts("You have instructed me to unzip the PTV General Transit Feed Specification file in order to compile a list of town names.")
         unzip_result = unzip_ptv_gtfs_file(input_path_name = input_path_name)
         if (unzip_result == true) then
            town_dictionary = return_town_dictionary_from_multiple_ptv_stop_files(input_path_name = input_path_name, town_field_num = 1, lat_field_num = 2, long_field_num = 3)
            town_list = return_town_list_from_town_dictionary(town_dictionary)
            return([town_list, town_dictionary])
         else
            return(result)
         end
      elsif (source_choice[0].upcase == 'V') then
         puts("You have instructed me to use VICMAP data to compile a list of town names.")
         town_dictionary = return_town_dictionary_from_vicmap_file(input_path_name = input_path_name)
         town_list = return_town_list_from_town_dictionary(town_dictionary)
         return([town_list, town_dictionary])
      else
         puts("Choice not in standard lists, please try again")
      end
      return(result)
   rescue
      puts("Error encountered, exiting.")
      return(result)
   end
end


def return_town_coordinate_dictionary(input_path_name)
   town_dictionary = return_town_dictionary_from_multiple_ptv_stop_files(path_name = input_path_name)
   vicmap_town_dictionary = return_town_dictionary_from_vicmap_file(input_path_name = input_path_name)
   town_dictionary.merge!(vicmap_town_dictionary)
   return(town_dictionary)
end


def return_town_dictionary_from_vicmap_file(input_path_name, file_name = 'vic_and_border_locality_list.csv')
   result = false
   begin
      if (input_path_name == nil) then
         input_path_name = Dir.pwd
      end
      full_file_name = File.join(input_path_name, file_name)
      town_dictionary = return_town_dictionary_from_single_file(file_name = full_file_name, file_type = 'vicmap', town_field_num = 3, lat_field_num = 11, long_field_num = 12, select_field_num = 6, select_field_value = 'VIC')
   rescue
      puts("Error encountered in return_town_dictionary_from_vicmap...")
      return(result)
   end
end


def return_town_dictionary_from_multiple_ptv_stop_files(input_path_name, default_stop_file_name='stops.txt', town_field_num=1, lat_field_num=2, long_field_num=3)
   result = false
   puts("Attempting to make town dictionary...")
   begin
      town_dictionary = Hash.new() 

      stop_file_list = Dir.glob("#{input_path_name}/**/#{default_stop_file_name}")
      puts(stop_file_list)

      stop_file_list.each do |stop_file_name|
         puts("Found PTV stop file: #{stop_file_name}")
         current_town_dictionary = return_town_dictionary_from_single_file(stop_file_name = stop_file_name, file_type = 'ptv', town_field_num = town_field_num, lat_field_num = lat_field_num, long_field_num = long_field_num)
         if (current_town_dictionary != false) then 
            puts("Adding #{current_town_dictionary.size} town references to dictionary.")
            town_dictionary.merge!(current_town_dictionary)
         end
         puts("Working through PTV list. Current unsorted town references: #{town_dictionary.size}")
      end      
      puts("Finished searching for town references in zipped files.")
      puts("Town count: #{town_dictionary.size}")
      town_dictionary_sorted = Hash[ town_dictionary.sort_by { |key, val| key } ]
      return(town_dictionary_sorted)
   rescue
      puts("Error encountered extracting towns from zipped PTV file, exiting...")
      return(result)
   end
end


def return_town_dictionary_from_single_file(file_name, file_type = 'ptv', town_field_num=1, lat_field_num=2, long_field_num=3, select_field_num=nil, select_field_value=nil)
   result = false
   puts("Attempting to make town dictionary from file #{file_name}")
   begin
      csv_contents = CSV.read(file_name)
      csv_contents.shift
      town_dictionary = Hash.new()
      csv_contents.each do |row|
         if (file_type == 'ptv') then
            town_name = pull_town_string_from_ptv_stop_string(row[town_field_num])
         elsif (file_type == 'vicmap') then
            town_name = pull_town_string_from_vicmap_string(row[town_field_num])
         else
            town_name = row[town_field_num]
         end     
         puts(town_name)
         if (select_field_num.nil? == false) then
            if (row[select_field_num] != select_field_value) then
               puts("Removing, #{row[select_field_num]} != #{select_field_value}")
               town_name = false
            end
         end

         if (town_name != false) then
            town_dictionary[town_name] = [Float(row[lat_field_num]), Float(row[long_field_num])]
         end
      end
      print_town_dictionary(town_dictionary)
      puts(town_dictionary.length)
      return(town_dictionary)

   rescue
      puts("Encountered error in return_town_dictionary_from_single_file...")
      return(result)
   end
end


def pull_town_string_from_ptv_stop_string(input_string, start_divider="(", end_divider=")")  
   result = false
   begin 
      input_string_parts = input_string.split(start_divider)
      if (input_string_parts.size != 2) then
         puts("String format for #{input_string} does not match PTV stop names, will skip...")
         return(result)
      else
         target_string = input_string_parts[1]
         town_string = target_string.split(end_divider)[0]
         return(town_string)
      end
   rescue
      puts("Encountered error in pull_town_string_from_ptv_stop_string, input #{input_string}, will skip...")
      return(result)
   end
end


def pull_town_string_from_vicmap_string(input_string)
   begin
      output_string = proper_case(input_string.split("(")[0])
      return(output_string)
   rescue
      puts("Error!")
      return(input_string)
   end
end


def return_town_list_from_town_dictionary(town_dictionary)
   result = false
   begin
      town_list = town_dictionary.map { |town, coordinates|
         town
      }
   rescue
      puts("Encountered error in return_town_list_from_town_dictionary...")
      return(result)
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



# POTENTIAL FUNCTION: READING LIST OF EXISTING FILES
# existing_tragedy_file_list = Array.new
# Dir.foreach(default_output_path) do |file_name|
#    if (file_name.include?("trove_result") and file_name.include?("tragedy")) then
#       existing_tragedy_file_list << file_name
#    end
# end
