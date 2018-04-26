require "csv"
require "json"
require "net/http"
require "nokogiri"
require "date"
require "rbconfig"
DEFAULT_ARTICLE_COUNT = 20

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
   puts(trove_api_request)

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
   
      csv << ["search_word", "search_town", "result_number", "trove_url", "trove_article_heading", "trove_article_title", "trove_article_", "trove_article_page", "trove_article_snippet"]
      
      trove_api_results.xpath('//article').each do |trove_article|
         result_count = result_count + 1      
         csv << [search_word, search_town, result_count, trove_article.xpath('troveUrl').text, trove_article.xpath('heading').text, trove_article.xpath('title').text, trove_article.xpath('date').text, trove_article.xpath('page').text, trove_article.xpath('snippet').text.gsub(/<strong>|<\/strong>/,"")]

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
     [row[4], row[6], row[8]]
   }.uniq

   prompt_suffix = "\n\t'n' to skip this article for reading "
   prompt_suffix += "\n\tcarriage return or 'y' to keep this article for reading" 

   # loop through and preview results
   i = 1
   input_trove[1..-1].each do |str_heading, str_date, str_snippet|      
   
      begin#error handling                  
      status = 0
       
      puts "\nArticle #{i}"
      puts "Heading: #{str_heading}"
      puts "Date: #{str_date}"
      puts "Snippet:\n#{str_snippet}"
            
      rescue Exception
         puts "Error at record #{i}"
      end#of error handling
      
      i += 1
   end

end


def read_trove_results(input_trove_file, read_all = false, max_articles = DEFAULT_ARTICLE_COUNT)
   # This method reads the Trove results aloud
   # The can skip articles if the user presses 'n'. It will pause at the end of each article.
   # Input: Trove file

   clear_screen()
   puts "\nREADING ARTICLES ******"
   
   if (read_all == false) then
      say_instruction "\nI can read the articles out loud. I will pause after each article. Press enter to read, or n to skip the article."
      prompt_suffix = "\n\t'n' to skip this article for reading "
      prompt_suffix += "\n\t'exit' to escape" 
      prompt_suffix += "\n\tAny other key to read this article now" 
   else
      prompt_suffix = "\n\t reading all articles"
   end

   # take only the fields of interest for reading aloud, into an array of trove results
   input_trove = CSV.read(input_trove_file).map { |row|
     [row[4], row[6], row[8]]
   }.uniq

   if (max_articles > input_trove.length) then
      max_articles = input_trove.length
   end

   i = 1
   input_trove[1..max_articles].each do |str_heading, str_date, str_snippet|
      
      begin#error handling 
      
         clear_screen()
      
         puts "\nArticle #{i}"
         puts "Heading: #{str_heading}"
         puts "Date: #{str_date}"
         puts "Snippet:\n#{str_snippet}"
               
         if (read_all == false) then
            response = get_user_input("\n\tContinue with article #{i}?" + prompt_suffix)
            response = response.downcase
         else
            response = "y"
         end
            
         if (response == "exit") then         
            return(false)
         
         elsif (response != "n") then
            # only proceed with the extra formatting if this article is to be said aloud
                  
            # fancy date format
            new_date = convert_date(str_date)

            # remove the first part of the snippet, which is the same as the headline
            str_snippet = str_snippet.gsub(str_heading, "")

            # remove annoying dart strings common to Trove...I don't know how to do this in one command rather than two
            str_snippet = str_snippet.gsub("...", " ")
            str_snippet = str_snippet.gsub("..", " ")
            str_snippet = remove_unfinished_sentence(str_snippet)

            # say the three items aloud
            puts "\t...Reading Article #{i}"
            puts("\nRead snippet:\n#{str_snippet}")
            
            say_something("date #{new_date}", also_print = false)
            say_something(str_heading, also_print = false, speed = 140)
            say_something("#{str_snippet}", also_print = false, speed = 140)

         end#of this record
      
      rescue Exception
         puts "Error at record #{i}"
      end#of error handling
      
      i += 1

   end#of reading through input_trove

   return(true)

end

# example of full text search http://api.trove.nla.gov.au/newspaper/203354793?&key={}&reclevel=full&include=articletext