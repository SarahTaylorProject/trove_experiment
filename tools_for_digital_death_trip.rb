require "csv"
require "net/http"
require "date"
require "rbconfig"
load 'tools_for_general_use.rb'

def return_town_list(source_choice, input_path_name)
   result = false
   begin
      if (source_choice[0].upcase == 'S') then
         puts("You have instructed me to use the exiting PTV STOP FILES to compile a list of town names.") 
         town_list = return_town_list_from_existing_ptv_stop_files(path_name = input_path_name)
         return(town_list)
      elsif (source_choice[0].upcase == 'P') then
         puts("You have instructed me to unzip the PTV General Transit Feed Specification file in order to compile a list of town names.")
         puts("Please wait while I process this. It can take some time.")
         unzip_result = unzip_ptv_gtfs_file(input_path_name = input_path_name)
         if (unzip_result == true) then
            town_list = return_town_list_from_existing_ptv_stop_files(input_path_name = input_path_name)
         else
            puts("\nSorry, could not complete the unzip of the GTFS file. You could try searching for existing stop files though.")
         end
         return(town_list)
      elsif (source_choice[0].upcase == 'V') then
         puts("You have instructed me to use VICMAP data to compile a list of town names.")
         town_list = return_town_list_from_vicmap(path_name = input_path_name)
         return(town_list)
      else
         puts("Choice not in standard lists, please try again")
      end
      return(result)
   rescue
      puts("Error encountered, exiting.")
      return(result)
   end
end


def return_town_list_from_existing_ptv_stop_files(input_path_name, default_stop_file_name='stops.txt', stop_field_num=1)
   result = false
   begin
      full_town_list = Array.new 
      
      stop_file_list = Dir.glob("#{input_path_name}/**/#{default_stop_file_name}")

      stop_file_list.each do |stop_file_name|
         puts(stop_file_name)
         puts("Found PTV stop file: #{stop_file_name}")
         current_town_list = return_town_list_from_single_ptv_stop_file(stop_file_name = stop_file_name, stop_field_num = stop_field_num)
         puts("Adding #{current_town_list.size} town references to unsorted town list.")
         full_town_list.concat current_town_list
         puts("Working through PTV list. Current unsorted town references: #{full_town_list.size}")
      end      
      town_list = full_town_list.sort.uniq
      puts("Finished searching for town references in zipped files.")
      puts("Sorted town count: #{town_list.size}")
      return(town_list)
   rescue
      puts("Error encountered extracting towns from zipped PTV file #{File.join(input_path_name, gtfs_file_name)}")
      return(result)
   end
end


def return_town_list_from_single_ptv_stop_file(stop_file_name, stop_field_num=1)
   result = []
   puts("Attempting to make town list from PTV stop file #{stop_file_name}")
   begin
      csv_contents = CSV.read(stop_file_name)
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


def unzip_ptv_gtfs_file(input_path_name, gtfs_file_name='gtfs.zip', path_numbers_to_unzip=[1, 2, 3, 4, 5, 6])
   # unzipping the gtfs format file: very particular, they are zipped-zipped files, with numbered subdirectories
   # returns true if successful in unzipping the main file and at least one zipped file from within this
   # returns false if errors enountered and/or no zipped file from within the initial zip file, is successfully unzipped
   result = false
   begin
      puts("Now unzipping the PTV GTFS file #{gtfs_file_name}")
      unzipped_path_list = Array.new
      gtfs_unzipped_path = unzip_single_file(input_file_name = gtfs_file_name, input_path_name = input_path_name)
      puts("1.1")
      puts(gtfs_unzipped_path)
      if (gtfs_unzipped_path == false) then
         return(result)
      end
      # unzip the zip files that came out of the initial unzip, but only for the specified path numbers
      path_numbers_to_unzip.each do |path_number|
         
         target_path = File.join(gtfs_unzipped_path, path_number.to_s)
         puts("Current target path: #{target_path}")
         zip_file_list = Dir.glob("#{target_path}/*.zip")
         puts("1.2")
         puts("zip file list:")
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


def return_town_list_from_vicmap(input_path_name, search_state='VIC', vicmap_csv_file_name='vic_and_border_locality_list.csv', town_field_num=5, state_field_num=6)
   result = []
   puts("Attempting to read VicMap town list from #{File.join(input_path_name, vicmap_csv_file_name)}")
   begin    
      full_file_name = File.join(input_path_name, vicmap_csv_file_name)
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



# POTENTIAL FUNCTION: READING LIST OF EXISTING FILES
# existing_tragedy_file_list = Array.new
# Dir.foreach(default_output_path) do |file_name|
#    if (file_name.include?("trove_result") and file_name.include?("tragedy")) then
#       existing_tragedy_file_list << file_name
#    end
# end
