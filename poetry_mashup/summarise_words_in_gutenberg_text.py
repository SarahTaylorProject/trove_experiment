import nltk
import random
import sys

from nltk.tokenize import RegexpTokenizer
from nltk.corpus import stopwords

stop_words = set(stopwords.words('english'))
tokenizer = RegexpTokenizer(r'\w+')
freq_limit = 50

corpus_file_id_list = [file_id for file_id in nltk.corpus.gutenberg.fileids()]

# will default to moby dick unless 'random' passed to command line
corpus_file_id = 'melville-moby_dick.txt'
if len(sys.argv) > 1:
    if (sys.argv[1].lower() == 'random'):
        corpus_file_id = random.choice(corpus_file_id_list)

print(f"Text: {corpus_file_id}")

corpus_raw = nltk.corpus.gutenberg.raw(corpus_file_id)
corpus_words_all = tokenizer.tokenize(corpus_raw)
print(f"\nWord count (including stop words): {len(corpus_words_all)}")

freq = nltk.FreqDist(corpus_words_all)
most_common = freq.most_common(30)
print(f"Most common {freq_limit} words (including stop words):")
print(most_common)

corpus_words = [w.lower() for w in corpus_words_all if w.lower() not in stop_words]
print(f"\nWord count (excluding stop words): {len(corpus_words)}")

freq = nltk.FreqDist(corpus_words)
most_common = freq.most_common(freq_limit)
print(f"Most common {freq_limit} words (excluding stop words):")
print(most_common)

common_word_list = []
for item in most_common:
    common_word_list.append(item[0])

test_words = ['man', 'woman', 'child', 'whale']
print(f"\nWord counts for: {test_words}")
corpus_test_words = [w.lower() for w in corpus_words if w.lower() in test_words]
freq = nltk.FreqDist(corpus_test_words)
most_common = freq.most_common(freq_limit)
print(most_common)

#nltk.download('averaged_perceptron_tagger')
freq_limit = 20
corpus_words_tagged = nltk.pos_tag(corpus_words)
tag_list = ['NN', 'NNS', 'JJ', 'VB', 'VBG']
for tag in tag_list:
    corpus_words_tag = [w[0] for w in corpus_words_tagged if w[1] == tag]
    freq = nltk.FreqDist(corpus_words_tag)
    most_common = freq.most_common(freq_limit)
    print(f"\nMost common {freq_limit} words of type {tag}:")
    print(most_common)

print(f"\nText: {corpus_file_id}")