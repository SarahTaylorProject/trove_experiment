require 'fileutils'
require 'csv'

def return_town_dictionary_from_existing_ptv_stop_files(input_path_name, default_stop_file_name='stops.txt', town_field_num=1, lat_field_num=2, long_field_num=3)
   result = false
   puts("Attempting to make town dictionary...")
   begin
      town_dictionary = Hash.new() 

      stop_file_list = Dir.glob("#{input_path_name}/**/#{default_stop_file_name}")

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


def return_town_dictionary_from_single_file(file_name, file_type = 'ptv', town_field_num=1, lat_field_num=2, long_field_num=3)
   result = false
   puts("Attempting to make town dictionary from file #{file_name}")
   begin
      puts(file_name)
      puts(file_type)
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
         if (town_name != false) then
            town_dictionary[town_name] = [Float(row[lat_field_num]), Float(row[long_field_num])]
         end
      end
      puts(town_dictionary)
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
   result = false
   begin
      output_string = proper_case(input_string.gsub(/\(.*\)/, "").strip!)
   rescue
      return(result)
   end
end

def proper_case(input_string)
   begin
      output_string = input_string.split(" ").map { |word|
         word.capitalize
      }.join(" ")
      return(output_string)
   rescue
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

system("clear")
# my_trove_key = read_trove_key()
search_word = 'tragedy'
default_speed = 180
default_output_path = File.join(Dir.pwd, 'output_files')
default_town_path_name = File.join(Dir.pwd, 'town_lists')

# stop_file_name = File.join(default_town_path_name, 'stops.txt')
# town_dictionary = return_town_dictionary_from_existing_ptv_stop_files(input_path_name = default_town_path_name)
# town_list = return_town_list_from_town_dictionary(town_dictionary)

# if (town_list != false) then
#    puts("Random town sample:")
#    sample_town_name = town_list.sample
#    puts(sample_town_name)
#    sample_town = town_dictionary[sample_town_name]
#    puts("Coordinates")
#    puts(sample_town)
#    require 'json'
#    File.open("test.json","w") do |f|
#      #f.write(town_dictionary.to_json)
#      f.write(JSON.pretty_generate(town_dictionary))
#    end
# end

# print_town_dictionary(town_dictionary)

vicmap_file_name = File.join(default_town_path_name, 'vic_and_border_locality_list.csv')
town_dictionary = return_town_dictionary_from_single_file(file_name = vicmap_file_name, file_type='vicmap', town_field_num = 3, lat_field_num = 11, long_field_num = 12)
town_list = return_town_list_from_town_dictionary(town_dictionary)

if (town_list != false) then
   puts("Random town sample:")
   sample_town_name = town_list.sample
   puts(sample_town_name)
   sample_town = town_dictionary[sample_town_name]
   puts("Coordinates:")
   puts(sample_town)
   require 'json'
   File.open("test.json","w") do |f|
     #f.write(town_dictionary.to_json)
     f.write(JSON.pretty_generate(town_dictionary))
   end
end
