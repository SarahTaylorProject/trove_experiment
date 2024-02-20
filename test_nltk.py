import nltk
import random

corpus_text = 'melville-moby_dick.txt'
corpus_file_id_list = [file_id for file_id in nltk.corpus.gutenberg.fileids() if 'shakespeare' not in file_id]
print(corpus_file_id_list)
corpus_file_id = random.choice(corpus_file_id_list)
print(corpus_file_id)

corpus_words = set(w.lower() for w in nltk.corpus.gutenberg.words(corpus_file_id))
print(corpus_words)

#custom_corpus_words_sorted = sorted(custom_corpus_words)


from nltk.corpus import stopwords
stop_words = set(stopwords.words('english'))

orpus_words = nltk.corpus.gutenberg.words('melville-moby_dick.txt')
print(corpus_words)c

words_l = [w.lower() for w in corpus_words if w.lower() not in stop_words]
print(words_l)
freq = nltk.FreqDist(words_l)
#print(freq)
print(freq.most_common(30))