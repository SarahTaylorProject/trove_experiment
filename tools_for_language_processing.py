import nltk
import sys

from nltk.tokenize import RegexpTokenizer
from nltk.tokenize import word_tokenize

def return_word_list_from_df(df, field_list=None, tokenizer=None):
    result = None
    try:
        word_list = []
        if (field_list == None):
            field_list = df.columns.tolist()
        if (tokenizer == None):
            tokenizer = RegexpTokenizer(r'\w+')
        for field_name in field_list:
            for current_string in df[field_name].tolist():
                if isinstance(current_string, str):
                    word_list.extend(tokenizer.tokenize(current_string))
        return(word_list)
    except:
        return(result)


def run_nltk_downloads():
    nltk.download('averaged_perceptron_tagger')
    # TODO: add other downloads here, call on error


def return_nltk_stop_words(language='english'):
    from nltk.corpus import stopwords
    stop_words = set(stopwords.words(language))
    return(stop_words)


def return_summary_of_most_common_words(input_words, freq_limit=10, description=''):
    current_summary = ''
    try:
        freq = nltk.FreqDist(input_words)
        most_common = freq.most_common(freq_limit)
        # print(most_common)
        common_word_list = []
        # TODO: refine the most useful part of this function; currently cluttered
        for item in most_common:
            word = item[0]
            common_word_list.append(word)
        current_summary += ", ".join(common_word_list)
        return(current_summary)
    except:
        return(current_summary)


def return_custom_word_summary_list(input_words_all, 
        freq_limit=15, 
        stop_words=None, 
        freq_limit_tag_summary=5,
        tag_list=['NN', 'VBG']):
    
    summary_list = []
    
    try:
        if (stop_words == None):
            stop_words = return_nltk_stop_words()

        current_summary = f"Word count (including stop words): {len(input_words_all)}"
        summary_list.append(current_summary)

        input_words = [w.lower() for w in input_words_all if w.lower() not in stop_words]
        current_summary = f"Word count (excluding stop words): {len(input_words)}"
        summary_list.append(current_summary)

        current_summary = f"Most common {freq_limit} words: \n"
        current_summary += return_summary_of_most_common_words(input_words=input_words, description="(excluding stop words)")
        summary_list.append(current_summary)

        input_words_tagged = nltk.pos_tag(input_words)
        tag_dict = return_nltk_tag_dict()

        for tag in tag_list:
            input_words_current_tag = [w[0] for w in input_words_tagged if w[1] == tag]
            current_summary = f"Most common words with tag '{tag}' ({tag_dict[tag]}): \n"
            current_summary += return_summary_of_most_common_words(input_words=input_words_current_tag,
                freq_limit=freq_limit_tag_summary)
            summary_list.append(current_summary)

        return(summary_list)
    except:
        print("error in summary")
        return(summary_list)


def return_nltk_tag_dict():
    tag_dict = {}
    tag_dict["NN"] = "noun singular"
    tag_dict["NNS"] = "noun plural"
    tag_dict["JJ"] = "adjective"
    tag_dict["JJR"] = "adjective, comparative"
    tag_dict["VB"] = "verb"
    tag_dict["VBG"] = "verb gerund"
    tag_dict["PRP"] = "personal pronoun"
    return(tag_dict)