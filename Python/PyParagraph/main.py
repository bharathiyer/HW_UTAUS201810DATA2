import os
import re
import string

def analyze_words(para):
    ''' In the given text, calculate:
    - word count and
    - average word-length
    '''
    # remove punctuations from text
    mytbl = para.maketrans('', '', string.punctuation)
    para = para.translate(mytbl)
    # split into words
    wordlist = para.split()
    # count number of words
    wordcount = len(wordlist)
    # calculate average word-length
    avgwordlen = sum([len(word) for word in wordlist])/wordcount

    return (wordcount, avgwordlen)
##end analyze_words(para)


def analyze_sentences(para):
    ''' In the given text, calculate:
    - sentence count and
    - average number of words per sentence
    '''
    # split into sentences
    sentencelist = re.split("(?<=[.!?]) +", para)
    # count number of sentences
    sentencecount = len(sentencelist)
    # calclulate average number of words per sentence
    avgsentencelen = sum([len(s.split()) for s in sentencelist])/sentencecount

    return (sentencecount, avgsentencelen)
##end analyze_sentences(para)


print('The directory raw_data has paragraph_1.txt and paragraph_2.txt')
fnum = input('Which file would you like to analyse - 1 or 2? ')
if fnum not in ['1', '2']:
    print('Wrong choice!')
    quit()

# open the file
fpath = os.path.join('raw_data', f'paragraph_{fnum}.txt')
with open(fpath, encoding='utf-8') as fhand:
    # read the entire file
    ftext = fhand.read()
    # remove quotes and newlines from text
    ftext = re.sub('"', '', ftext)
    ftext = re.sub("'", '', ftext)
    ftext = re.sub("\n", ' ', ftext)

    # analyze words and sentences
    (wcount, avgwlen) = analyze_words(ftext)
    (scount, avgslen) = analyze_sentences(ftext)
    print('Paragraph Analysis')
    print('-----------------')
    print(f'Approximate Word Count: {wcount}')
    print(f'Approximate Sentence Count: {scount}')
    print(f'Average Letter Count: {avgwlen:.01f}')
    print(f'Average Sentence Length: {avgslen:.01f}')
