# Trove API Experiment
Version at January 18th 2017, very similar to December 2017

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

Notes January 18th 2018:
This version doesn't hard-code the trove API key, it gets it from an accompanying file ("my_api.txt")


Notes in December 2017:
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

## GENERAL COMMENTS
The program works but has a lot of overheads for the setup. 
When the program runs well, it can be both memorable and emotionally affecting. When the program runs poorly it is just distracting and annoying!
The program should be spruced up but – more importantly – be used as a stepping stone to other ideas. It is a proof of a general concept but needn't be so specific.

## IMPROVEMENTS TO DO:
o	A visual interface, with greater flexibility and lower overheads for setup;
o	A general cleanup of code is needed. It is clunky and embarrassing at times, not modular enough. It was written quickly and with a low level of familiarity with Ruby. There are many opportunities to improve efficiency, clarity and error catching. 
o	The search terms could definitely be more effective for comprehensiveness, e.g. sorting results differently (to avoid repetition), and/or adding newspaper information to make the geography of the searches smarter (not just sending the raw text of a town name). 
o	There could be the option for fetching the whole article rather than the snippets (some articles sound promising but are cut off bluntly);
o	The ability to graph or map the results somehow (so, not just reading out loud), will be very exciting, as the ability to see historical events tied to geographical locations tends to make them more “real” (plus more entertaining); 
o	Improving user experience in many ways: speed, access (not just through command line), GUI, less reliance on writing a csv, etc. 
o	More map-based elements, geographical searches
o	More ability for multiple users and ongoing improvements, rather than something that only runs on a computer with Ruby and with very specific files present. This is where a web based application would be great.
o	More inclusion of interesting mashups: e.g. interacting with Twitter to send search terms.
