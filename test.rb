require 'fileutils'
require 'csv'
require 'json'
load 'tools_for_towns.rb'
load 'tools_for_general_use.rb'

def make_town_geojson(town_name, coordinates=[0, 0])
   geojson_object = {
      "type" => "FeatureCollection", 
      "features" => [
         {
            "type" => "Feature", 
            "geometry" => {"type" => "Point", "coordinates" => coordinates},
            "properties" => {"town_name" => town_name, "search_term" => "tragedy"}
         }
      ]
   }
   puts(geojson_object)
end

default_town_path_name = File.join(Dir.pwd, 'town_lists')

vicmap_file_name = File.join(default_town_path_name, 'vic_and_border_locality_list.csv')
town_data = return_town_data(source_type = 'V', main_path_name = default_town_path_name)
town_list = town_data[0]
town_dictionary = town_data[1]
print_town_dictionary(town_dictionary)
search_town = town_list.sample

if (town_list != false) then
   puts("Random town sample:")
   sample_town_name = town_list.sample
   puts(sample_town_name)
   sample_town = town_dictionary[sample_town_name]
   puts("Coordinates:")
   puts(sample_town)
   town_geojson = make_town_geojson(town_name = sample_town, coordinates = town_dictionary[sample_town_name])
   # File.open("test.json","w") do |f|
   #   f.write(JSON.pretty_generate(town_geojson))
   # end
end




# type": "FeatureCollection",
#     "features": [
#       { "type": "Feature",
#         "geometry": {"type": "Point", "coordinates": [102.0, 0.5]},
#         "properties": {"prop0": "value0"}
#         },
