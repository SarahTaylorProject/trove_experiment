# Trove API Experiment

## Usage for 'digital_death_trip'
```
ruby digital_death_trip.rb
```

## Usage for 'call_the_bible_and_poetry'
```
python call_the_bible_and_poetry.py
```

## Note at August 2018

Use 'ruby digital_death_trip.rb'

First you have the option to:
- choose a search town yourself; or
- let the program choose a search town for you, using the town list; or
- choose to use one of the existing result CSV files (if any) so as to not need the internet

Then (if you are not using an existing CSV file):
- it will search the Trove API for 'tragedy' and this town name; then
- it will write the results to a CSV file
- it will preview some headlines

Then it will read a random article or read a specific article
And give the option to keep trying different articles
And write the article to html

Then it will write all existing files to a geojson

## Requirements

"digital death trip" requires Ruby

"call_the_bible_and_poetry" requires Python 3 (no fancy packages though - just 'requests' and 'json')

Both programs rely on internet access, as they will send requests to API's. 

The Taylor Project lyrics are just a text file, that should be located in the same directory (in future this may move to an online repository)

Speaking is big part.
On Linux and Mac the "speak" function is in-built and the "say_something" functions take this into account.

To hear any speaking on Windows, you will need to install the free speaking package 'espeak', and set up an environment variable for the command line executable.
http://espeak.sourceforge.net/download.html
Otherwise, you will only see the results, not hear them


## Limitations
Does not deal with the full result list from Trove, only the first 100 results per search.
The search is very simplified: just the town name string, not a clever geographic search. 
The Trove API will change later in 2018, so the address and parsing will need to be updated.

## General Comments
The program works but has a lot of overheads for the setup. 
When the program runs well, it can be both memorable and emotionally affecting. 
When the program runs poorly it is just distracting and annoying!

## Improvements Needed/Ideas
- A general cleanup of code is needed. It is clunky and embarrassing at times, not modular enough. It was written quickly and with a low level of familiarity with Ruby. There are many opportunities to improve efficiency, clarity and error catching. 
- Greater use of the map files it creates; plus more sophisticated map production than just centroids;
- The search terms could definitely be more effective for comprehensiveness, e.g. sorting results differently (to avoid repetition), and/or adding newspaper information to make the geography of the searches smarter (not just sending the raw text of a town name). 
- Improving user experience in many ways: speed, access (not just through command line), GUI, less reliance on writing a csv, etc. 
- More map-based elements, geographical searches.
- A web based application would be great, to reduce reliance on command line. But this is not necessarily needed for the podcast concept.
- More inclusion of interesting mashups: e.g. interacting with Twitter to send search terms.
