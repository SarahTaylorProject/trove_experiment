require 'fileutils'
require 'csv'
require 'json'
load 'tools_for_towns.rb'
load 'tools_for_general_use.rb'

def make_single_town_article_geojson_object(town_name, town_coordinates=[0, 0], article_properties={})
   geojson_object = {
      "type"=> "Feature", 
      "geometry"=> {"type"=> "Point", "coordinates"=> town_coordinates}, 
      "properties"=> {"town_name"=> town_name}.merge!(article_properties)
   }
   return(geojson_object)
end

def make_collection_of_geojson_objects(geojson_array)
   geojson_object = {
      "type"=> "FeatureCollection", 
      "features"=> geojson_array
   }
   return(geojson_object)
end

def make_trove_file_geojson_array(input_trove_file, town_name, town_coordinates, write_individual_article_json = false, article_numbers = Array(1..DEFAULT_ARTICLE_COUNT))
   # ADD METHOD NOTES HERE
   # ADD ERROR HANDLING
   # note: resulting json files will read better if can translate the headline reader into dictionary outputs

   input_trove = CSV.read(input_trove_file).map { |row|
     [row[4], row[6], row[8], row[9]]
   }.uniq
   # NOTE ADD TOWN AND SEARCH TERM HERE
   geojson_array = []

   i = 1
   input_trove[1..-1].each do |str_heading, str_date, str_snippet, str_trove_id|
      begin
         if (article_numbers.include? i) then
            article_properties = {"headline"=> str_heading, "date"=> str_date, "snippet"=> str_snippet, "trove_id" => str_trove_id}
            geojson_object = make_single_town_article_geojson_object(town_name = town_name, town_coordinates = town_coordinates, article_properties = article_properties)
            geojson_array.push(geojson_object)
            
            if (write_individual_article_json == true) then
               output_file_name = "map_" + File.basename(input_trove_file).split(".")[0] + "_article_" + str_trove_id + ".json"
               output_file_name = File.join(File.dirname(input_trove_file), output_file_name)
               puts("Article #{i} in #{input_trove_file}.\nWriting single article geojson object to:\n#{output_file_name}")
               File.open(output_file_name, "w") do |f|
                  f.write(JSON.pretty_generate(geojson_object))
               end
            end
         end
      rescue Exception
         puts "Error at record #{i}"
      end
      i += 1
   end
   return(geojson_array)
end

def write_geojson_for_all_csv_files(town_path_name, output_path_name)
   # ADD METHOD NOTES HERE
   result = false
   begin
      output_file_name = File.join(output_path_name, "map_collection_" + Time.now.strftime("%d_%m_%Y") + ".json")
      csv_file_list = return_existing_trove_file_list(output_path_name = output_path_name)

      puts("\nFound #{csv_file_list.size} output files, will try to create geojson file #{output_file_name}...")

      town_dictionary = return_town_dictionary_from_both_sources(town_path_name = town_path_name)
      print_town_dictionary(town_dictionary)

      full_geojson_array = []

      i = 1
      csv_file_list.each do |file_name|
         town_name = File.basename(file_name)
         #town_name = town_name[/#{"trove_result_"}(.*?)#{"_tragedy.csv"}/m, 1].gsub("_", " ")
         town_name = return_trove_file_search_town(input_trove_file = file_name)
         puts(town_name)
         town_coordinates = town_dictionary[town_name]
         puts("\nProcessing geojson for output file #{i}\n#{file_name}.\nTown name: #{town_name}, Coordinates: #{town_coordinates}")
         current_geojson_array = make_trove_file_geojson_array(input_trove_file = file_name, town_name = town_name, town_coordinates = town_coordinates)
         full_geojson_array.push(*current_geojson_array)
         i += 1
      end

      geojson_collection = make_collection_of_geojson_objects(full_geojson_array)
      File.open(output_file_name, "w") do |f|
         f.write(JSON.pretty_generate(geojson_collection))
      end
      puts("HERE...")
      puts("\nMap collection geojson file for ALL Trove outputs in directory:\n#{output_file_name}\n")
      puts("Total of #{full_geojson_array.size} map objects, from #{i} files.")
      return(full_geojson_array.size)
   rescue
      puts("Encountered error in 'write_geojson_for_all_csv_files'...")
      return(result)
   end
end