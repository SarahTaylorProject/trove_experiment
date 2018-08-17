load 'tools_for_general_use.rb'
load 'tools_for_trove.rb'

def fetch_trove_newspaper_article(trove_article_id, trove_key)
   current_search_word = convert_phrase_string_for_url(current_search_word)
   # note: April 2018 search word may suit treatment as multiple words, not string literal
   current_search_town = convert_phrase_string_for_url(current_search_town)

   #trove_api_request = "http://api.trove.nla.gov.au/result?key="
   trove_api_request = "http://api.trove.nla.gov.au/newspaper/#{trove_article_id}?key=#{trove_key}&reclevel=full&include=articletext"
   #trove_api_request = trove_api_request + "#{trove_key}&zone=newspaper&q=#{current_search_word}+AND+#{current_search_town}"

   begin
      uri = URI(trove_api_request)
      response = Net::HTTP.get(uri)
      trove_api_results = Nokogiri::XML.parse(response)
   rescue
      puts "Error getting API results"
      return(0)
   end

   return(trove_api_results)

end

# MAIN TEST
clear_screen()
my_trove_key = read_trove_key()
search_word = 'tragedy'
default_speed = 180
default_output_path_name = File.join(Dir.pwd, 'output_files')
unless File.directory?(default_output_path_name)
   FileUtils.mkdir_p(default_output_path_name)
end
max_articles_to_read = 3
continue = true

article_id_list = ["209449335", "228412100", "107330126", "10732364"]

puts(article_id_list)

# example of full text search http://api.trove.nla.gov.au/newspaper/203354793?&key={}&reclevel=full&include=articletext

trove_article_result = fetch_trove_newspaper_article(trove_article_id = article_id_list[0], trove_key = my_trove_key)
puts(trove_article_result)