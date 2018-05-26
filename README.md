# Trove API Experiment

## Usage for 'digital_death_trip'
```
ruby digital_death_trip.rb
```

## Usage for 'call_the_bible_and_poetry'
```
python call_the_bible_and_poetry.py
```

## the 'call_the_olden_days.rb' file has been largely superseded by 'digital_death_trip.rb'

## Requirements
"digital death trip" requires Ruby
"call_the_bible_and_poetry" requires Python 3 (no fancy packages though - just 'requests' and 'json')
Both programs rely on internet access, as they will send requests to API's. 
The Taylor Project lyrics are just a text file, that should be located in the same directory (in future this may move to an online repository)
On Linux and Mac the "speak" function is in-built and the "say_something" functions take this into account.
To hear any speaking on Windows, you will need to install the free speaking package 'espeak', and set up an environment variable for the command line executable.
http://espeak.sourceforge.net/download.html
Otherwise, you will only see the results


### Notes from May 2018
Most of the focus is now on the 'digital_death_trip.rb' file, as this will be used for a podcast prototype.
It can now write results to geojson, using just the centroid objects to represent search localities. 
It can read all existing output files and write these into one big geojson. 
This is suirted to Google Maps but more work is needed to make this open.


### Notes from April 2018
Now includes the "call_the_bible_and_poetry" set of Python files, used at Taylor Project gig in April 2018.


### Notes from January 2018
This version doesn't hard-code the trove API key, it gets it from an accompanying file ("my_api.txt")


### Notes from December 2017
This version can now run on Windows with the prerequisite that the user installs 'espeak' and has
a shortcut to the espeak command line tool, in their system PATH variable. 
This will mean it can
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
The search is very simplified: just the town name string, not a clever geographic search. 

## General Comments
The program works but has a lot of overheads for the setup. 
When the program runs well, it can be both memorable and emotionally affecting. When the program runs poorly it is just distracting and annoying!

## Improvements Needed/Ideas
- A general cleanup of code is needed. It is clunky and embarrassing at times, not modular enough. It was written quickly and with a low level of familiarity with Ruby. There are many opportunities to improve efficiency, clarity and error catching. 
- Greater use of the map files it creates; plus more sophisticated map production than just centroids;
- The search terms could definitely be more effective for comprehensiveness, e.g. sorting results differently (to avoid repetition), and/or adding newspaper information to make the geography of the searches smarter (not just sending the raw text of a town name). 
- There could be the option for fetching the whole article rather than the snippets (some articles sound promising but are cut off bluntly);
- Improving user experience in many ways: speed, access (not just through command line), GUI, less reliance on writing a csv, etc. 
- More map-based elements, geographical searches.
- A web based application would be great, to reduce reliance on command line. But this is not necessarily needed for the podcast concept.
- More inclusion of interesting mashups: e.g. interacting with Twitter to send search terms.
