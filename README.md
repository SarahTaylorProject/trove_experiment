# Trove API Experiment
Updates April 26th 2017

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
This version has radically downsized the curating function, but still retains user input on what to say
or not to say out loud.
It previews the articles first, then goes through each article one at a time, with the user having
the option to read the article. 

## Limitations
Does not deal with the full result list from Trove, only the first 100 results per search
This version has more methods rather than line-by-line code, but it is still pretty messy

## TODO:
Search could be more effective for comprehensiveness
e.g. sorting results differently (to avoid repetition), or possibly fetching the whole article rather than the snippet
Clean up more code
THink through options for improving search results. And improving speedy user experience.
Also need to find a way to share without sharing my API!
