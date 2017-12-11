require "csv"
require "json"
require "net/http"
require "nokogiri"
require "date"
require "rbconfig"

# GENERAL METHODS

def say_something(text, also_print = true, speed = 150)
   # This method says text aloud through the command line
   # Checks for operating system and uses appropriate say-aloud command line
   # Works for linux and mac, could expand to others later
   # Will print text either way
   # If also_print is true, then the text is sent to puts as well
 
   if (also_print == true) then
      puts(text)
   end

   result = operating_system()

   case result
      when "linux"
         `echo "#{text}"|espeak -s #{speed}`
      when "mac"
         `say -r #{speed} "#{text}"`
      when "windows"
         `espeak -s#{speed} "#{text}"`
      else
         puts "say_something does not yet support this operating system"
   end     

end

def say_instruction(text)
   # This method will say instructions out loud IF the environment permits this
   # otherwise it will just send the text to puts
   # It will not ask say_something to print it again!

   puts(text)

   if(ENV["SAY_EVERYTHING"] == "true") then
      say_something(text, also_print = false)
   end 

end

def get_user_input(prompt_text = "\nPlease enter value")
   # This method just gets direct input from the user with a prompt
   # Returns the user input
   # Nothing fancy, just a handy function

   if (prompt_text.length > 0) then
      puts prompt_text  
   end
   input_text = STDIN.gets.chomp
   return(input_text)

end

def clear_screen()
   system("clear")
end

def operating_system()
   # This method checks the operating system name and returns this, if it is in the list
   # Requires 'rbconfig' to run
   # Returns "unknown" if operating system is not recognised

   include RbConfig
   os_name = "unknown"

   case CONFIG['host_os']
   when /linux|arch/i
      os_name = "linux"
   when /darwin/i
      os_name = "mac"
   when /mswin|windows/i
      os_name = "windows"
   when /mingw32/i
   	   os_name = "windows"
   when /sunos|solaris/i
      os_name = "solaris"
   end

   return(os_name)

end

def convert_date(text)
   new_date_array = text.split(/\/|\-/).map(&:to_i)
   new_date = Date.new(*new_date_array)
   new_date.strftime("%Y %d %B")
end


# TROVE-SPECIFIC METHODS

def fetch_trove_results(current_search_town, current_search_word, trove_key)
   # This method constructs a single search request for Trove (of a very specific format!) 
   # Input: two search parameters (town name, and search term) and the API key 
   # Return: XML of results (if successful) or 0 if error encountered
   # Note: will not necessarily fail if no results returned
   # The search town and search term are currently both just passed as strings, eventually the town search will be expanded
   # December 2017 this was altered to use net::HTTP rather than curl, as this is more reliable on Windows

   current_search_word = current_search_word.gsub(/\s/, "%20")
   current_search_town = current_search_town.gsub(/\s/, "%20")

   trove_api_request = "http://api.trove.nla.gov.au/result?key="
   trove_api_request = trove_api_request + "#{trove_key}&zone=newspaper&encoding&q=#{current_search_word}+AND+#{current_search_town}"

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

def read_trove_results(input_trove_file)
   # This method reads the Trove results aloud
   # The can skip articles if the user presses 'n'. It will pause at the end of each article.
   # Input: Trove file

   clear_screen()
   puts "\nREADING ARTICLES ******"
   say_instruction "\nI can read the articles out loud. I will pause after each article. Press enter to read, or n to skip the article."
   # take only the fields of interest for reading aloud, into an array of trove results
   input_trove = CSV.read(input_trove_file).map { |row|
     [row[4], row[6], row[8]]
   }.uniq

   prompt_suffix = "\n\t'n' to skip this article for reading "
   prompt_suffix += "\n\t'exit' to escape" 
   prompt_suffix += "\n\tAny other key to read this article now" 


   i = 1
   input_trove[1..-1].each do |str_heading, str_date, str_snippet|
      
      begin#error handling 
      
         clear_screen()
      
         puts "\nArticle #{i}"
         puts "Heading: #{str_heading}"
         puts "Date: #{str_date}"
         puts "Snippet:\n#{str_snippet}"
               
         response = get_user_input("\n\tContinue with article #{i}?" + prompt_suffix)
         response = response.downcase

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

            # say the three items aloud
            puts "\t...Reading Article #{i}"
            
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


# TROVE MAIN PROCEDURE

continue = true
clear_screen()
puts "\nSTART TROVE EXPERIMENT ******\n"

# my Trove API key and default searches
my_trove_key = 'lop9t29sfm35vfkq'
default_town = 'Elmore'
default_search = 'tragedy'

puts "Hello. This is an experiment. I can call the olden days. I make use of the National Library of Australia Trove database."
puts "I send a search request to the Trove API, with your nominated search town and search word."
puts "All results will be written to a csv file that you can keep. I will then proceed with a live reading."
puts "You will have a chance to curate the articles, before I preceed with the live reading."

say_instruction("Hello. This is an experiment. I can call the olden days. I make use of the National Library of Australia Trove database.")
say_instruction("\nPlease enter a search town in Australia. (This will default to '#{default_town}', you can press enter to leave this unchanged, or type 'exit' to escape)")

search_town = get_user_input("")
if (search_town.length == 0) then
   search_town = default_town
elsif (search_town.downcase == "exit") then
   continue = false
end

if (continue == true) then
   say_something(search_town)
end

if (continue == true) then
   say_instruction("Please enter a search word. (This will default to '#{default_search}', you can press enter to leave this unchanged, or type 'exit' to escape)")
   search_word = get_user_input("")
   if (search_word.length == 0) then
      search_word = default_search
   elsif (search_word.downcase == "exit") then
      continue = false
   end
end

if (continue == true) then
   say_something(search_word)
end

if (continue == true) then
   say_instruction("Thankyou. Calling the olden days about #{search_town} #{search_word}.")
   say_instruction("Connecting to Trove database now.")

   trove_api_results = fetch_trove_results(search_town, search_word, my_trove_key)
   output_file_name = "trove_result_#{search_town}_#{search_word}.csv".gsub(/\s/,"_")

   puts("\nWriting all results to file now...")
   result_count = write_trove_results(trove_api_results, output_file_name, search_word, search_town)

   puts "\nSearch town: \n\t#{search_town}"
   puts "Search term: \n\t#{search_word}"
   puts "Result count: \n\t#{result_count}"
   puts "Results written to: \n\t#{output_file_name}"
end

if (continue == true) then
   if (result_count > 0) then
      say_something("#{result_count} articles available about #{search_town} #{search_word}")      
   else
      say_instruction("Sorry, no results to read. Please try again. Sometimes the Trove API is busy with other requests.")
      continue = false
   end
end

if (continue == true) then
   say_instruction "\n\nPreviewing results."
   preview_trove_results(output_file_name)
end

if (continue == true) then
   # pause before continuing, give user the chance to exit   
   say_instruction "\n\nFinished previewing results. Press enter to continue to READING articles out loud, or type 'exit' to escape."
   response = get_user_input("")
   if (response.downcase == "exit") then
      continue = false
   end 
end

if (continue == true) then
   read_trove_results(output_file_name)
   say_instruction("\nFinished reading articles about #{search_town} #{search_word}.")
end

say_instruction "\nThankyou for taking part in this experiment."

puts "\nEND TROVE EXPERIMENT ******\n"