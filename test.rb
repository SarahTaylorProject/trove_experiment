require 'fileutils'
require 'csv'
require 'json'
load 'tools_for_towns.rb'
load 'tools_for_general_use.rb'
DEFAULT_ARTICLE_COUNT = 20


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

def make_trove_file_geojson_array(input_trove_file, town_name, town_coordinates, article_numbers = Array(1..DEFAULT_ARTICLE_COUNT))
   # note: shows concept, but will read better if can translate the headline reader into dictionary outputs

   input_trove = CSV.read(input_trove_file).map { |row|
     [row[4], row[6], row[8], row[9]]
   }.uniq

   geojson_array = []

   i = 1
   input_trove[1..-1].each do |str_heading, str_date, str_snippet, str_trove_id|
      begin
         if (article_numbers.include? i) then
            article_properties = {"headline"=> str_heading, "date"=> str_date, "snippet"=> str_snippet, "trove_id" => str_trove_id}
            geojson_object = make_single_town_article_geojson_object(town_name = town_name, town_coordinates = town_coordinates, article_properties = article_properties)
            geojson_array.push(geojson_object)
            #puts(geojson_array.size)
         end
      rescue Exception
         puts "Error at record #{i}"
      end
      i += 1
   end
   #puts(geojson_array.size)
   return(geojson_array)

end


default_town_path_name = File.join(Dir.pwd, 'town_lists')
default_output_path = File.join(Dir.pwd, 'output_files')

# vicmap_file_name = File.join(default_town_path_name, 'vic_and_border_locality_list.csv')
# town_data = return_town_data(source_type = 'V', main_path_name = default_town_path_name)
# town_list = town_data[0]
# town_dictionary = town_data[1]
# print_town_dictionary(town_dictionary)
# search_town = town_list.sample

town_coordinate_dictionary = return_town_coordinate_dictionary(input_path_name = default_town_path_name)
print_town_dictionary(town_coordinate_dictionary)

csv_file_list = Dir.glob("#{default_output_path}/**/*tragedy.csv")

full_geojson_array = []

csv_file_list.each do |file_name|
   town_name = File.basename(file_name)
   town_name = town_name[/#{"trove_result_"}(.*?)#{"_tragedy.csv"}/m, 1].gsub("_", " ")
   puts(town_name)
   town_coordinates = town_coordinate_dictionary[town_name]
   puts(town_coordinates)
   current_geojson_array = make_trove_file_geojson_array(input_trove_file = file_name, town_name = town_name, town_coordinates = town_coordinates)
   puts(current_geojson_array.size)
   full_geojson_array.push(*current_geojson_array)
   puts(full_geojson_array.size)
   #puts(current_geojson_array)
end
puts(full_geojson_array)
collection_geojson = make_collection_of_geojson_objects(full_geojson_array)
File.open("test_collection.json","w") do |f|
   f.write(JSON.pretty_generate(collection_geojson))
end

# if (town_list != false) then
#    puts("Random town sample:")
#    sample_town_name = town_list.sample
#    puts(sample_town_name)
#    sample_town = town_dictionary[sample_town_name]
#    puts("Coordinates:")
#    puts(town_dictionary[sample_town_name])

#    puts(geojson_array)
#    town_geojson = make_collection_of_geojson_objects(geojson_array = geojson_array)
#    File.open("test.json","w") do |f|
#      f.write(JSON.pretty_generate(town_geojson))
#    end
# end
