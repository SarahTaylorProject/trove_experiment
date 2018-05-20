require "csv"
require "net/http"
require "date"
require "rbconfig"
load 'tools_for_talking.rb'

def return_town_list(source_choice, main_path_name, default_speed=180)
   result = false
   begin
      if (source_choice[0].upcase == 'E' or source_choice.upcase == 'EXISTING PTV STOP FILES') then
         say_something("You have instructed me to use the EXISTING PTV STOP FILES to compile a list of town names.", also_print = true, speed = default_speed) 
         town_list = return_town_list_from_existing_ptv_stop_files(path_name = main_path_name)
         return(town_list)
      elsif (source_choice[0].upcase == 'P' or source_choice.upcase == 'PTV GTFS ZIP FILE') then
         say_something("You have instructed me to UNZIP the PTV General Transit Feed Specification file in order to compile a list of town names.", also_print = true, speed = default_speed)
         say_something("Please wait while I process this. It can take some time.", also_print = true, speed = default_speed)                  
         unzip_result = unzip_ptv_gtfs_file(main_path_name = main_path_name)
         if (unzip_result == true) then
            town_list = return_town_list_from_existing_ptv_stop_files(main_path_name = main_path_name)
         else
            puts("Sorry, could not unzip file. You could try searching for existing stop files though.")
         end
         return(town_list)
      elsif (source_choice[0].upcase == 'V' or source_choice.upcase == 'VICMAP') then
         say_something("You have instructed me to use VICMAP data to compile a list of town names.", also_print = true, speed = default_speed)
         town_list = return_town_list_from_vicmap(path_name = main_path_name)
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


def return_town_list_from_existing_ptv_stop_files(main_path_name, main_file_name='gtfs.zip', default_stop_file_name='stops.txt', stop_field_num=1)
   result = false
   begin
      full_town_list = Array.new 
      
      stop_file_list = Dir.glob("#{main_path_name}/**/#{default_stop_file_name}")

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
      puts("Error encountered extracting towns from zipped PTV file #{File.join(main_path_name, main_file_name)}")
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


def unzip_ptv_gtfs_file(main_path_name, main_file_name='gtfs.zip', path_numbers_to_unzip=[1, 2, 3, 4, 5, 6])
   # unzipping the gtfs format file: very particular, they are zipped-zipped files, with numbered subdirectories
   # returns true if successful in unzipping the main file and at least one zipped file from within this
   # returns false if errors enountered and/or no zipped file from within the initial zip file, is successfully unzipped
   result = false
   begin
      puts("Now unzipping the PTV GTFS file #{main_file_name}")
      unzipped_path_list = Array.new
      main_unzipped_path = unzip_single_file(file_name = main_file_name, path_name = main_path_name)
      if (main_unzipped_path == false) then
         return(result)
      end
      # unzip the zip files that came out of the initial unzip, but only for the specified path numbers
      path_numbers_to_unzip.each do |path_number|
         
         target_path = File.join(main_unzipped_path, path_number.to_s)
         puts("Current target path: #{target_path}")
         zip_file_list = Dir.glob("#{target_path}/**/*.zip")
         
         zip_file_list.each do |file_name|       
            unzipped_path = unzip_single_file(file_name = file_name, path_name = target_path)      
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
      puts("Error encountered unzipping PTV file #{File.join(main_path_name, main_file_name)}")
      return(result)
   end
end


def unzip_single_file(file_name, path_name=Dir.pwd, overwrite=true, output_path_name=nil)
   # unzips a single zip file
   # most code borrowed from https://gist.github.com/robc/217400
   # returns the output path if successful, or false if error encountered
   # if output_path_name is left as nil then it will construct a default output location using zip file norms
   result = false
   begin
      full_file_name = File.join(path_name, file_name)
      if (output_path_name == nil) then
         output_path_name = File.join(path_name, File.basename(file_name, '.zip'))
      end
      result = unzip_file_with_7z_command(full_file_name=full_file_name, output_path_name=output_path_name, overwrite=overwrite)
      if (result == false) then
         result = unzip_file_with_unzip_command(full_file_name=full_file_name, output_path_name=output_path_name, overwrite=overwrite)
      end
      return(output_path_name)

   rescue   
      puts("Error encountered with unzipping #{file_name}") 
      return(result)
   end
end


def unzip_file_with_unzip_command(full_file_name, output_path_name, overwrite=true)
   # tries unzipping with the 'unzip' command, returns true if successful, false if error encountered
   result = false
   begin
      puts("unzip_file_with_unzip_command")
      command_string = "unzip "
      if (overwrite == true) then
         command_string += "-o "
      end
      command_string += full_file_name + " -d " + output_path_name
      puts(command_string)
      system(command_string)
      puts("Successfully unzipped #{full_file_name} to #{output_path_name} using 'unzip' command")
      result = true
      return(result)
   rescue
      puts("Error encountered with unzipping #{full_file_name} to #{output_path_name}using 'unzip' command")
      return(result)
   end
end


def unzip_file_with_7z_command(full_file_name, output_path_name, overwrite=true)
   # tries unzipping with the 'unzip' command line, returns true if successful, false if error encountered
   result = false
   begin
      puts("unzip_file_with_7z_command")
      if (operating_system() == 'windows') then
         command_string = "7z"
      else
         command_string = "7za"
      end
      command_string += " x " 
      if (overwrite == true) then
         command_string += "-aoa "
      end
      command_string += full_file_name + " -o" + output_path_name
      puts(command_string)
      system(command_string)
      puts("Successfully unzipped #{full_file_name} to #{output_path_name} using '7z' command")
      result = true
      return(result)
   rescue
      puts("Error encountered with unzipping #{full_file_name} to #{output_path_name} using '7z' command")
      return(result)
   end
end


def return_town_list_from_vicmap(main_path_name, search_state='VIC', vicmap_csv_file_name='vic_and_border_locality_list.csv', town_field_num=5, state_field_num=6)
   result = []
   puts("Attempting to read VicMap town list from #{File.join(main_path_name, vicmap_csv_file_name)}")
   begin    
      full_file_name = File.join(main_path_name, vicmap_csv_file_name)
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


# POTENTIAL FUNCTION: READING LIST OF EXISTING FILES
# existing_tragedy_file_list = Array.new
# Dir.foreach(default_output_path) do |file_name|
#    if (file_name.include?("trove_result") and file_name.include?("tragedy")) then
#       existing_tragedy_file_list << file_name
#    end
# end
