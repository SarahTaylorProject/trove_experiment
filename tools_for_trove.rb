require "csv"
require "json"
require "net/http"
require "nokogiri"
require "date"
require "rbconfig"
load 'tools_for_talking.rb'
DEFAULT_ARTICLE_COUNT = 20


def read_trove_key(my_trove_file = "my_trove.txt")
   begin
      my_trove_key = File.read("my_trove.txt")
   rescue
      my_trove_key = get_user_input(prompt_text = "\nPlease enter trove key, could not find #{my_trove_file}")
   end
   return(my_trove_key)
end


def fetch_trove_results(current_search_town, current_search_word, trove_key)
   # This method constructs a single search request for Trove (of a very specific format!) 
   # Input: two search parameters (town name, and search term) and the API key 
   # Return: XML of results (if successful) or 0 if error encountered
   # Note: will not necessarily fail if no results returned
   # The search town and search term are currently both just passed as strings, eventually the town search will be expanded
   # December 2017 this was altered to use net::HTTP rather than curl, as this is more reliable on Windows

   current_search_word = convert_phrase_string_for_url(current_search_word)
   # note: April 2018 search word may suit treatment as multiple words, not string literal
   current_search_town = convert_phrase_string_for_url(current_search_town)

   trove_api_request = "http://api.trove.nla.gov.au/result?key="
   trove_api_request = trove_api_request + "#{trove_key}&zone=newspaper&q=#{current_search_word}+AND+#{current_search_town}"
   #puts(trove_api_request)

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


def write_trove_results(trove_api_results, output_file_name, search_word, search_town)
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


def preview_trove_results(input_trove_file)
   # This method previews the main fields of all articles
   # Input: a csv of Trove search results, written as above in the 'write_trove_results' method
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
      puts "Headline: #{str_heading}"
      puts "Date: #{str_date}"
      puts "Preview of article content:\n#{str_snippet}"
            
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
            puts "\nArticle: #{i}"
            puts "trove_id: #{str_trove_id}"
            puts "Headline: #{str_heading}"
            puts "Date: #{str_date}"
            puts "Preview of content:\n#{str_snippet}"
            
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

# example of full text search http://api.trove.nla.gov.au/newspaper/203354793?&key={}&reclevel=full&include=articletext

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
            puts("\nArticle: #{i}")            
            read_trove_article(str_heading = str_heading = str_heading, str_date = str_date, str_snippet = '', speed = speed, year_only = true, also_print = true)
         end
      
      rescue Exception
         puts "Error at record #{i}"
      end#of error handling
      
      i += 1

   end#of reading through input_trove

   return(true)

end


def read_trove_article(str_heading='', str_date='', str_snippet='', speed = 180, year_only = false, also_print = false)

   begin#error handling                           
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
            say_something("#{str_sentence}", also_print = also_print, speed = speed)
         end
      end
     
   rescue Exception
      puts "Error at record #{i}"
   end#of error handling   

   return(true)

end