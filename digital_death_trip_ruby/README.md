# Trove API Experiment


# Digital Death Trip

As featured in the Digital Death Trip podcast instalments :)
example: https://soundcloud.com/david-nichols-738987609/the-pyramid-hill-tragedy-1906-the-lie-of-the-land-digital-death-trip-investigatesep-1-of-3
and: https://soundcloud.com/david-nichols-738987609/the-tatura-tragedy-1905-death-of-a-hired-man-digital-death-trip-investigates


### Usage for 'digital_death_trip'
```
ruby digital_death_trip.rb

(but make sure to have a valid Trove API in subfolder named 'keys')

```

## Notes at November 2019

Code for 'digital death trip' is mostly unchanged since August 2018. 
This code helps to select random towns and random tragedies from the National Library of Australia Trove database. 
It also talks to you while making these selections. 
See example use here: https://soundcloud.com/david-nichols-738987609/the-pyramid-hill-tragedy-1906-the-lie-of-the-land-digital-death-trip-investigatesep-1-of-3

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

Then it will write all existing files to a geojson file. 
Note that this component (the geojson/geographic part of giving extra information about a tragedy) is not as much developed/tested as other parts of the Digital Death Trip code, as our podcast use has tended to favour the talking part rather than the map part. 


## Requirements

"digital death trip" requires Ruby

It also requires that a valid Trove API key is in a subfolder named 'keys'
It needs a town list in the 'town_lists' subfolder. An example is included (vic_and_border_locality_list.csv). 
The fancier Victorian town list built from PTV stops is also possible, if a gtfs.zip file is included in this subfolder.
The latter is a much bigger file so is not included by default. 

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


# Also includes: Poetry mashup (in progress)

The 'poetry_mashup.py' program is in progress, it is a Python script that compiles random poetry from chosen inputs. 

It asks for a line count. It looks in three sources: 
- the Bible API
- the online Poetry database API
- and any text files found in the 'poetry_input_files_current' subfolder (some examples are included here)

For the given number of poetry lines, one at a time, it does the following:
- Randomly chooses the source from the meta source list (Bible, poetry, or text file). 
- Then it picks randomly within the meta source: 
- For the Bible it randomly chooses from a list of Bible book names, then tries random numbers to get a verse within that book (will continue asking the Bible API for the book and verse combination until a successful call is made, i.e. the book and verse exists, or until the limit number is exceeded)
- For the Poetry database it randomly chooses from a list of Poet names, then selects a random poem from the return result (if successful), then selects a random line from that poem. 

In so doing, the poetry_mashup can assemble random poems. 

It writes the result to a file called 'random_poem_output_[date suffix].txt' in the 'poetry_output_files' folder
It includes a list of sources it used. 
It also writes the poem to screen and attempts to say it aloud, if a speaking capability is found. 

Example output:

Hello. I will assemble a poem, using a random mix of quotes.Ok. How many quotes would you like me to collect?

I used the following sources:
1-taylor_project_lyrics_sample.txt
2-Genesis 12:13
3-rmit_performance.txt
4-taylor_project_lyrics_sample.txt
5-taylor_project_lyrics_sample.txt
6-centrelink_not_meeting_obligations.txt
7-rmit_performance.txt
8-centrelink_demerits.txt
9-centrelink_not_meeting_obligations.txt
10-Genesis 19:26

HERE IS MY POEM
Could hardly wait to begin the whole affair
Say I pray thee thou art my sister that it may be well with me for thy sake and my soul shall live because of thee
that helps you assess your current skills and create an individually-tailored development plan for you to achieve your goals
It takes a long long time for our bones to dry
Jo-jo-jnah and the whale
You may also get a serious failure if you don't accept a suitable job offer
To do so you'll participate in outcome-focussed performance and career planning
agreeing to or changing your plan if asked
for not meeting their requirements without a reasonable excuse
But his wife looked back from behind him and she became a pillar of salt

End of poem. Thanks for listening.



## Usage for 'poetry_mashup'
```
python poetry_mashup.py

(place any text files of interest in subfolder named 'poetry_input_files_current')
```

## Requirements (poetry_mashup)
"poetry_mashup" requires Python 3 (no fancy packages though - just 'requests' and 'json')

## Notes (poetry_mashup)
This is a work in progress! But it is funny when it works. 
There are some sample text file inputs provided but you should add more for interest value. 
You will need to manually change the 'meta_source_list' in poetry_mashup.py if you wish it NOT to call the Bible and the Poetry database. 
If you want to exclude those API calls from the mix, just say meta_source_list = []