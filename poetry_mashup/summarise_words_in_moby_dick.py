import nltk
import random
import sys

from nltk.tokenize import RegexpTokenizer
from nltk.corpus import stopwords

stop_words = set(stopwords.words('english'))
tokenizer = RegexpTokenizer(r'\w+')
freq_display_count = 50

corpus_file_id_list = [file_id for file_id in nltk.corpus.gutenberg.fileids()]
corpus_file_id = 'melville-moby_dick.txt'
#corpus_file_id = random.choice(corpus_file_id_list)
print(f"Text: {corpus_file_id}")

corpus_raw = nltk.corpus.gutenberg.raw(corpus_file_id)
corpus_words_all = tokenizer.tokenize(corpus_raw)
print(f"\nWord count (including stop words): {len(corpus_words_all)}")

freq = nltk.FreqDist(corpus_words_all)
most_common = freq.most_common(30)
print(f"Most common {freq_display_count} words (including stop words):")
print(most_common)

corpus_words = [w.lower() for w in corpus_words_all if w.lower() not in stop_words]
print(f"\nWord count (excluding stop words): {len(corpus_words)}")

freq = nltk.FreqDist(corpus_words)
most_common = freq.most_common(freq_display_count)
print(f"Most common {freq_display_count} words (excluding stop words):")
print(most_common)

common_word_list = []
for item in most_common:
    common_word_list.append(item[0])

test_words = ['man', 'woman', 'child']
print(f"\nWord counts for: {test_words}")
corpus_test_words = [w.lower() for w in corpus_words if w.lower() in test_words]
freq = nltk.FreqDist(corpus_test_words)
most_common = freq.most_common(freq_display_count)
print(most_common)