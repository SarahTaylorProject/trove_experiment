import nltk
import os
import string
import sys
import traceback

from nltk.corpus import stopwords
from nltk.corpus import words

from nltk.tokenize import word_tokenize

# from tools_for_general_use import *

def download_nltk_corpus_list(corpus_list=['stopwords', 'punkt', 'brown', 'gutenberg']):
    result = False
    try:
        for corpus in corpus_list:
            nltk.download(corpus)
        result = True
        return(result)
    except:
        print("Error downloading nltk corpus list")
        return(result)


def return_word_dist(input_text, exclude_stopwords=True, result_count=10):
    result = None
    try:
        all_words = nltk.tokenize.word_tokenize(input_text)
        print(len(all_words))
        if (exclude_stopwords == True):
            word_dist = nltk.FreqDist(w.lower() for w in all_words if w not in stopwords)
        else:
            word_dist = nltk.FreqDist(w.lower() for w in all_words)
        return(word_dist)
    except:
        print("Error finding most common words...")
        return(result)


# TESTS

corpus_file_id = 'melville-moby_dick.txt'
# corpus_file_id_list = [file_id for file_id in nltk.corpus.gutenberg.fileids() if 'shakespeare' not in file_id]
#corpus_file_id = random.choice(nltk.corpus.gutenberg.fileids())

corpus = str(nltk.corpus.gutenberg(corpus_file_id))
corpus_words = set(w.lower() for w in nltk.corpus.gutenberg.words(corpus_file_id))
corpus_words_sorted = sorted(corpus_words)

corpus_word_dist = return_word_dist(corpus)
print(corpus_word_dist)