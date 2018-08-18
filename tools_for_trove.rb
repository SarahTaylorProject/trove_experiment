require "csv"
require "json"
require "net/http"
require "nokogiri"
require "date"
require "rbconfig"
load 'tools_for_general_use.rb'

def read_trove_key(my_trove_file = "my_trove.txt", my_directory = "keys")
   # Read Trove key from text file, first try in directory, then try file name without directory
   begin
      full_file_name = File.join(my_directory, my_trove_file)
      if not File.exist?(full_file_name)
         full_file_name = my_trove_file
      end
      my_trove_key = File.read(full_file_name)
   rescue
      my_trove_key = get_user_input(prompt_text = "\nPlease enter trove key, could not find #{full_file_name}")
   end
   return(my_trove_key)
end

def fetch_trove_search_results(current_search_town, current_search_word, trove_key)
   # This method constructs a single search request for Trove (of a very specific format!) 
   # Input: two search parameters (town name, and search term) and the API key 
   # Return: XML of results (if successful) or 0 if error encountered
   # Note: will not necessarily fail if no results returned
   # The search town and search term are currently both just passed as strings, eventually the town search will be expanded
   # December 2017 this was altered to use net::HTTP rather than curl, as this is more reliable on Windows

   current_search_word = convert_phrase_string_for_url(current_search_word)
   # note: April 2018 search word may suit treatment as multiple words, not string literal
   # note: should build search phrase here, loop through: upper and proper case, and different order for split words
   current_search_town = convert_phrase_string_for_url(current_search_town)

   trove_api_request = "http://api.trove.nla.gov.au/result?key="
   trove_api_request = trove_api_request + "#{trove_key}&zone=newspaper&q=#{current_search_word}+AND+#{current_search_town}"

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

def write_trove_search_results(trove_api_results, output_file_name, search_word, search_town)
   # This method writes the Trove XML results to a csv file, one article at a time
   # Input: XML results, output file name, search term and search town 
   # (the latter are just written to the csv to help assess results later)
   # the '//article' key word signals the start of a Trove article
   # Each article counts as a result
   # Returns: the result count after writing the file

   result_count = 0

   CSV.open(output_file_name, 'w') do |csv|
   
      csv << ["search_word", "search_town", "result_number", "trove_url", "trove_article_heading", "trove_article_title", "trove_article_", "trove_article_page", "trove_article_snippet", "trove_id"]
      
      trove_api_results.xpath('//article').each do |trove_article|
         result_count = result_count + 1      
         csv << [search_word, search_town, result_count, trove_article.xpath('troveUrl').text, trove_article.xpath('heading').text, trove_article.xpath('title').text, trove_article.xpath('date').text, 
            trove_article.xpath('page').text, trove_article.xpath('snippet').text.gsub(/<strong>|<\/strong>/,""), trove_article.attr('id')]

       end#of article
   end#of writing csv
   return(result_count)
end

def count_trove_search_results_from_csv(input_trove_file)
   input_trove = CSV.read(input_trove_file)
   return(input_trove.size - 1)
end

# NOTE: here make a function "count trove search results total"
# AND: function to count trove total results

def preview_trove_search_results_from_csv(input_trove_file)
   # This method previews the main fields of all articles
   # Input: a csv of Trove search results, written as above in the 'write_trove_search_results' method
   # Note: Only takes in the more interesting parts of Trove results: heading (field 4), date (field 6), snippet (field 8)

   puts "\nPREVIEW ARTICLES ******"
   puts "Input from: #{input_trove_file}"
   
   # take only the fields of interest for reading aloud, into an array of trove results
   input_trove = CSV.read(input_trove_file).map { |row|
     [row[4], row[6], row[8], row[9]]
   }.uniq

   # loop through and preview results
   i = 1
   input_trove[i..-1].each do |str_heading, str_date, str_snippet, str_trove_id|      
   
      begin#error handling                  
      status = 0
       
      puts "\nArticle: #{i}"
      puts "trove_id: #{str_trove_id}"
      puts "Headline:\n#{str_heading}"
      puts "Date:\n#{str_date}"
      puts "Content preview:\n#{str_snippet}"
            
      rescue Exception
         puts "Error at record #{i}"
      end#of error handling
      
      i += 1
   end  
   article_count = i - 1
   return(article_count)
end

def read_trove_results_by_array(input_trove_file, article_numbers = Array(1..5), speed = 180)
   # This method reads the Trove results aloud, given an array of articles to read
   # Input: Trove file, array of article numbers to read out

   clear_screen()
   puts("\nREADING ARTICLES #{article_numbers}******")
   
   # take only the fields of interest for reading aloud, into an array of trove results
   input_trove = CSV.read(input_trove_file).map { |row|
     [row[4], row[6], row[8], row[9]]
   }.uniq

   i = 1
   input_trove[1..-1].each do |str_heading, str_date, str_snippet, str_trove_id|
      begin#error handling 
         clear_screen()                
         if (article_numbers.include? i) then
            puts "\nArticle:#{i}"
            puts "trove_id: #{str_trove_id}"
            puts "Headline:\n#{str_heading}"
            puts "Date:\n#{str_date}"
            puts "Content:\n#{str_snippet}"
            
            say_something("Article #{i}", also_print = false, speed = speed)
            read_trove_article(str_heading = str_heading, str_date = str_date, str_snippet = str_snippet)
         end#of this record
      rescue Exception
         puts "Error at record #{i}"
      end#of error handling
      i += 1
   end#of reading through input_trove
   return(true)
end

def read_trove_headlines(input_trove_file, speed = 180, article_numbers = Array(1..DEFAULT_ARTICLE_COUNT))
   # This method reads the Trove results aloud, given an array of articles to read
   # Input: Trove file, array of article numbers to read out

   clear_screen()
   puts("\nREADING DATES AND HEADLINES ******")
   
   # take only the fields of interest for reading aloud, into an array of trove results
   input_trove = CSV.read(input_trove_file).map { |row|
     [row[4], row[6], row[8], row[9]]
   }.uniq

   i = 1
   input_trove[1..-1].each do |str_heading, str_date, str_snippet, str_trove_id|
      begin#error handling
         if (article_numbers.include? i) then     
            say_something("\nArticle: #{i}", also_print = true, speed = speed)    
            read_trove_article(str_heading = str_heading = str_heading, str_date = str_date, str_snippet = '', speed = speed, year_only = true, also_print = true)
         end
      rescue Exception
         puts "Error at record #{i}"
      end#error handling 
      i += 1
   end

   return(true)

end

def read_trove_article(str_heading='', str_date='', str_snippet='', speed = 180, year_only = false, also_print = false)
   begin                         
      if (str_date != '') then
         new_date = convert_date(str_date)
         if (year_only == true) then
            new_date = return_year_from_date_string(str_date)
            say_something("Year: ", also_print = also_print, speed = speed)
         else
            say_something("Date: ", also_print = also_print, speed = speed)
         end
         say_something("#{new_date}", also_print = also_print, speed = speed)
      end

      if (str_heading != '') then
         say_something("Headline:", also_print = also_print, speed = speed)
         str_heading_array = str_heading.split(".")
         str_heading_array.first(3).each do |str_sentence|
            say_something("#{str_sentence}", also_print = also_print, speed = speed)
         end
      end
           
      if (str_snippet != '') then
         str_snippet_new = str_snippet.gsub(str_heading, "")
         str_snippet_new = str_snippet_new.gsub("...", " ")
         str_snippet_new = str_snippet_new.gsub("..", " ")
         str_snippet_array = str_snippet_new.split(".")
         say_something("Content preview:", also_print = also_print, speed = speed)
         str_snippet_array.each do |str_sentence|
            say_something("#{str_sentence.strip()}", also_print = also_print, speed = speed)
         end
      end   
   rescue Exception
      puts "Error at record #{i}"
   end   
   return(true)
end

def return_existing_trove_file_list(output_path_name, also_print = false)
   existing_trove_file_list = []
   begin
      existing_trove_file_list = return_matching_file_names(input_path = output_path_name, 
         file_extension = "csv", 
         file_pattern = "trove_result")
      if (also_print == true) then
         print_existing_trove_file_list(existing_trove_file_list)
      end
      return(existing_trove_file_list)
   rescue
      puts("Encountered error in 'return_existing_trove_file_list'...")
      return(existing_trove_file_list)
   end
end

def print_existing_trove_file_list(existing_trove_file_list)
   begin
      existing_trove_file_list.each do |file_name|
         search_town = return_trove_file_search_town(file_name)
         search_word = return_trove_file_search_word(file_name)
         result_count = count_trove_search_results_from_csv(file_name)
         puts("#{File.basename(file_name)} (#{search_word}, #{search_town}, #{result_count} results)")
      end
   rescue
      return
   end
end

def return_trove_file_search_town(input_trove_file, search_town_field=1)
   # Returns the town name for a Trove CSV file, by using the first row 
   # This is marginally easier than inferring the search town from the file name
   # If errors encountered, returns blank string
   # If successful, returns the search town name from the Trove search result CSV file (defaults to field 1)
   search_town = ''
   begin
      search_town = CSV.read(input_trove_file)[1][search_town_field]
      return(search_town)
   rescue
      puts("Error encountered in 'return_trove_file_search_town', returning #{search_town}...")
      return(search_town)
   end
end

def return_trove_file_search_word(input_trove_file, search_word_field=0)
   # Returns the search word for a Trove CSV file, by using the first row 
   # This is marginally easier than inferring the search word from the file name
   # If errors encountered, returns blank string
   # If successful, returns the search word from the Trove search result CSV file (defaults to field 0)
   search_word = ''
   begin
      search_word = CSV.read(input_trove_file)[1][search_word_field]
      return(search_word)
   rescue
      puts("Error encountered in 'return_trove_file_search_word', returning #{search_word}...")
      return(search_word)
   end
end

def fetch_trove_newspaper_article(trove_article_id, trove_key)
   # Added August 18th: fetches individual article
   # Note: add more functions to handle this kind of return value
   puts("\nFetching individual article: #{trove_article_id}...")
   trove_api_request = "http://api.trove.nla.gov.au/newspaper/#{trove_article_id}?key=#{trove_key}&reclevel=full&include=articletext"
   puts(trove_api_request)
   begin
      uri = URI(trove_api_request)
      response = Net::HTTP.get(uri)
      trove_api_results = Nokogiri::XML.parse(response)
      puts(trove_api_results)
   rescue
      puts "Error getting API results"
      return(0)
   end

   return(trove_api_results)

end

def write_trove_newspaper_article_to_file(trove_article_result, trove_article_id, output_path_name)
   # This method writes the Trove XML results of an individual article, to a text file
   # Input: XML results, Trove article ID, output path name 
   output_file_name = File.join(output_path_name, "trove_article_" + trove_article_id)

   open(output_file_name, 'w') do |f|
      f.puts(trove_article_result)
      # note: need to decide whether to process the text or just leave it as is
      # maybe just process the text for TALKING, use this process here
      # trove_article_result.xpath('//articleText').each do |article_xml|
      #    article_text = article_xml.text.gsub("span&gt;", "").gsub(/<span>|<\/span>/,"")
      #    article_text = article_text.gsub("</p>", "\n")
      #    article_text = article_text.gsub("<p>", "").lstrip
       # end#of article
   end#of writing text file
   return(output_file_name)
end