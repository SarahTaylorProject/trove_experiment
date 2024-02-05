# Digital Death Trip

As featured in the Digital Death Trip podcast instalments, the Digital Death Trip script is an homage to "Wisconsin Death Trip", and a (dark) exploration of the historical events we often have collective amnesia about. "Tragedy" is a popular euphemism for violence. These tragedies tend to generate a spot of news coverage and horror, then collective amnesia. The randomness of a script is better suited to searching these than humans. 

Example uses of Digital Death Trip in podcast episodes: 

https://soundcloud.com/david-nichols-738987609/the-pyramid-hill-tragedy-1906-the-lie-of-the-land-digital-death-trip-investigatesep-1-of-3

https://soundcloud.com/david-nichols-738987609/the-tatura-tragedy-1905-death-of-a-hired-man-digital-death-trip-investigates


## To use 'digital_death_trip'
```
1. Obtain a valid Trove API key https://trove.nla.gov.au/about/create-something/using-api
2. Paste the API key into a file named keys/my_trove.txt
3. Run:

``` python digital_death_trip.py
```


## Notes at February 2024

Digital Death Trip was recently updated to:
- Use Python instead of Ruby
- Use the new Trove API version (v3)
- Take advantage of the possibility of multiple search result pages

As before, the Digital Death Trip code helps to select random towns and random tragedies from the National Library of Australia Trove database. 
It also talks to you while making these selections. 

First you have the option to:
- choose a search town yourself; or
- let the program choose a search town for you, using the town list; or
- choose to use one of the existing result CSV files (if any) so as to not need the internet

Then (if you are not using an existing CSV file):
- it will search the Trove API for 'tragedy' and this town name; then
- it will write the results to a CSV file
- it will preview some headlines

Then it will then write the results to a CSV file, and make multiple calls to get extra results (up to a given limit)
Note: doesn't yet do the part of reading out random more articles.


See example use here: https://soundcloud.com/david-nichols-738987609/the-pyramid-hill-tragedy-1906-the-lie-of-the-land-digital-death-trip-investigatesep-1-of-3


## Requirements

"digital death trip" requires Python.
It also requires that a valid Trove API key is in a subfolder named 'keys'
In order to speak it will need to run on Linux or Mac (with the "speak" function in-built), or for Windows, you will need to install the free speaking package 'espeak'.
http://espeak.sourceforge.net/download.html
Otherwise, you will only see the results, not hear them.


## Limitations
The search is very simplified: just the town name string, not a clever geographic search. 


## General Comments
The program works but has a lot of overheads for the setup. 
When the program runs well, it can be both memorable and emotionally affecting. 
When the program runs poorly it is just distracting and annoying!

## Improvements Needed/Ideas
- Need to update to bring across/ replicate the last parts of (v1) functionality from Ruby to Python: reading headlines, picking random article, and fetching article.
- Code cleanup.
- More flexibility in search terms.
- More map smarts.
- Summaries of themes and words, e.g. using NLTK
- More map-based elements, geographical searches.
- A web based application would be great, to reduce reliance on command line. But this is not necessarily needed for the podcast concept.
- More inclusion of interesting mashups: e.g. interacting with Twitter to send search terms.

