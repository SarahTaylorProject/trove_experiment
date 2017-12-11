# Trove API Experiment
Updates December 6th 2017

Searches Trove (National Library of Australia) for historical articles matching input town name and search term
Writes results to csv file and then proceeds to read them aloud with the "say_something" method

## Usage
### without instructions read aloud:
```
ruby call_the_olden_days.rb
```
### with instructions read aloud:
```
SAY_EVERYTHING=true ruby call_the_olden_days.rb
```

## Changes
This version can now run on Windows with the prerequisite that the user installs 'espeak' and has
a shortcut to the espeak command line tool, in their system PATH variable. This will mean it can
"talk" from the command line just like the Mac and Linux machines can by default. 
http://espeak.sourceforge.net/download.html

It also uses a different option to Curl (Net::HTTP.get), for retrieving the API results, as this was not 
behaving on Windows. 

These Windows changes are important because I don't have a mac at home or at work now, so unless I
pester someone else to bring a Mac, I can't run it. This version can run on my dodgy old Windows laptop.

As per previous versions, it previews the articles first, then goes through each article one at a time, 
with the user having the option to read the article. 

## Limitations
Does not deal with the full result list from Trove, only the first 100 results per search
This version has more methods rather than line-by-line code, but it is still pretty messy

## TODO:
Search could be more effective for comprehensiveness
e.g. sorting results differently (to avoid repetition), or possibly fetching the whole article rather than the snippet
Clean up more code
THink through options for improving search results (e.g. town names with spaces). And improving speedy user experience.
Also need share without sharing my API key!!

I currently aim to keep this Ruby script working and useful, while simulteneously moving over to a more generic 
"call the internet" set of tools in Python, which can call the olden days or call Youtube comments, etc. 