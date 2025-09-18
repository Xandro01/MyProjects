import csv
import re
import nltk
import emoji
nltk.download('punkt_tab')  # Download the updated punkt model
from nltk.tokenize import sent_tokenize, word_tokenize
from context import Context
from ngram_probabilities import NgramProbabilityMatrix

import random




def process_moby_dick_to_corpus(txt_file_path):
    """
    Process Moby-Dick text file and create a corpus with special tokens.
    
    Args:
        txt_file_path (str): Path to the text file containing Moby-Dick
        
    Returns:
        list: corpus array where each element is a processed sentence
    """
    corpus = []
    
    with open(txt_file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Remove chapter headers and table of contents
    # Split by chapters
    chapters = re.split(r'CHAPTER \d+\..*?\n\n', content)
    
    # Remove initial table of contents and metadata
    # Start from first actual chapter content
    main_text = ""
    for i, chapter in enumerate(chapters):
        if i == 0: 
            continue
         # Only substantial content
        if len(chapter.strip()) > 50: 
            main_text += chapter + " "
    
    # Clean the text
    # Remove extra whitespace and line breaks
    cleaned_text = re.sub(r'\n+', ' ', main_text)
    cleaned_text = re.sub(r'\s+', ' ', cleaned_text).strip()

    
    # Split into paragraphs (double line breaks in original become sentence boundaries)
    paragraphs = re.split(r'\.(?:\s|$)', cleaned_text)
    
    for paragraph in paragraphs:
        # Only non-empty paragraphs
        if paragraph and len(paragraph.strip()) > 0:  
            paragraph = paragraph.strip()
            
            # Tokenize into sentences
            sentences = sent_tokenize(paragraph + '.', language='english')
            
            processed_sentences = []
            for sentence in sentences:
                 # Only non-empty sentences
                if sentence and len(sentence.split()) > 0:
                    # Clean sentence
                    sentence = re.sub(r'[^\w\s.,;:!?-]', '', sentence)  
                    sentence = re.sub(r'\s+', ' ', sentence).strip()
                    
                    if sentence:
                        processed_sentences.append(f"<s> {sentence} </s>")
            
            # Add all sentences from this paragraph as one corpus entry
            if processed_sentences:
                corpus.append(" ".join(processed_sentences))
    
    return corpus


def process_tweets_to_corpus(csv_file_path):
    """
    Process tweets from CSV file and create a corpus with special tokens.
    
    Args:
        csv_file_path (str): Path to the CSV file containing tweets
        
    Returns:
        list: corpus array where each element is a processed sentence
    """
    corpus = []
    
    with open(csv_file_path, 'r', encoding='utf-8') as file:
        csv_reader = csv.reader(file)
        
        # Skip header row
        next(csv_reader)
        
        
        for row in csv_reader:
            # Extract text content (5th column, index 4)
            tweet_text = row[4]
            # Remove URLs starting with https
            cleaned_text = re.sub(r'https\S+', '', tweet_text)
            
            # Remove hashtags and mentions
            # cleaned_text = re.sub(r'@\w+', '', cleaned_text)  
            # cleaned_text = re.sub(r'#\w+', '', cleaned_text)  
            
            #   Remove special characters
            cleaned_text = re.sub(r'[^\w\s.;:]', '', cleaned_text)  
            #remove numbers
            
            # Clean up extra whitespace
            cleaned_text = re.sub(r'\s+', ' ', cleaned_text).strip()
            if cleaned_text:  # Only process non-empty tweets
                # Tokenize into sentences
                sentences = sent_tokenize(cleaned_text, language='italian')
                processed_sentence = ""
                for sentence in sentences:
                    if sentence:  # Only process non-empty sentences
                        processed_sentence = processed_sentence+f"<s> {sentence} </s>"
            
            corpus.append(processed_sentence)
                    
          
    
    return corpus


def custom_tokenize(text):
    """
    Custom tokenizer that preserves special tokens and emojis as single units.
    """
    # Replace special tokens with placeholders
    text = text.replace('<s>', ' __START_TOKEN__ ')
    text = text.replace('</s>', ' __END_TOKEN__ ')
    
    # Extract emojis and replace with placeholders
    emoji_dict = {}
    counter = 0
    
    # Find emojis using the emoji library
    for char in text:
        if char in emoji.EMOJI_DATA:
            if char not in emoji_dict:
                placeholder = f'__EMOJI_{counter}__'
                emoji_dict[placeholder] = char
                counter += 1
            else:
                # Find existing placeholder for this emoji
                placeholder = [k for k, v in emoji_dict.items() if v == char][0]
            
            text = text.replace(char, f' {placeholder} ', 1)
    
    # Tokenize normally
    tokens = word_tokenize(text)
    
    # Replace placeholders back to original tokens
    tokens = [token.replace('__START_TOKEN__', '<s>').replace('__END_TOKEN__', '</s>') for token in tokens]
    
    # Replace emoji placeholders back to emojis
    for placeholder, emoji_char in emoji_dict.items():
        tokens = [token.replace(placeholder, emoji_char) for token in tokens]
    
    return tokens
    
  



#from an input corpuss generate for each sentence a list of tokens and use it to update An hashmap <String, count> for unigram frequency
#And Context objects for ngram (n is a parameter) frequency
def generate_ngrams(corpus, n=3):
    """
    Generate n-grams from the corpus and update frequency counts.
    
    Args:
        corpus (list): List of sentences from the corpus
        n (int): Size of the n-grams to generate
        
    Returns:
        tuple: (unigram_counts, ngram_contexts)
            - vocabulary_size
            - ngram_contexts: List of Context objects for n-grams
    """
    unigram_counts = {}
    ngram_contexts = []
    
    for sentence in corpus:
        tokens = custom_tokenize(sentence)

        # Update unigram counts
        for token in tokens:
            if token in unigram_counts:
                unigram_counts[token] += 1
            else:
                unigram_counts[token] = 1
        
        # Get n-grams and their contexts
        for i in range(len(tokens) - n+1):
            ngram = list(tokens[i:i + n])
            # Create context from n-gram (all tokens except the last one)
            context_tokens = ngram[:-1] 
            context = Context(context_tokens=context_tokens)
            
            if(context not in ngram_contexts):
                ngram_contexts.append(context)
            else:
                index = ngram_contexts.index(context)
                context = ngram_contexts[index]
            
            # Update context counts (count of word that follows the context)
            next_token = ngram[-1]
            context.update_counts(next_token)
        
    # Create vocabulary from unigram counts
    vocabulary = list(unigram_counts.keys())

    return ngram_contexts, vocabulary


def generate_sentence_from_context(context: Context, matrix, max_length, temperature = 1.0, ngram_size=4):
    """
    Generate a sentence based on the context and probability matrix.
    
    Args:
        context (Context): Context object containing tokens and counts
        matrix (list): Probability matrix for n-grams
        
    Returns:
        str: Generated sentence
    """
    sentence = ""
    
    iteration = 0
    
    # Start with the context tokens
    for token in context.context_tokens:
        sentence = sentence + " " + token
    
    current_context = context
    
    stop_generating = False
    #fino a quando non genera come next token un </s>
    while not stop_generating and iteration < max_length:
        
        # Get the word that maximizes the n-gram probability for the current context
        #best_word = matrix.get_word_maximize_ngram_probability(current_context)
        
        best_word = matrix.get_word_with_temperature(current_context, temperature=temperature)
        
        if best_word is None:
            break
        
        sentence = sentence + " " + best_word
        #if best_word == '<s>' and current_context.context_tokens[-1] == '<s>':
         #   stop_generating = True
        # get new current context = cuttentcontext[ngram_size-1:] + [best_word]
        current_context_tokens = current_context.context_tokens[(ngram_size-(ngram_size-1)):] + [best_word]
        current_context = Context(context_tokens=current_context_tokens)
        iteration += 1
    #replace <s> and </s> with empty string
    sentence = sentence.replace('<s>', '').replace('</s>', '').strip()
    return sentence
    

def generate_tweet(context: Context, matrix, max_length=280, temperature=1.0, ngram_size=3):
    """
    Generate a tweet starting from a context containing '<s>' until '</s>' is generated.
    
    Args:
        context (Context): Context object containing tokens (should include '<s>')
        matrix (NgramProbabilityMatrix): Probability matrix for n-grams
        max_length (int): Maximum length of generated tweet (default 280 chars)
        temperature (float): Temperature for word selection
        ngram_size (int): Size of n-grams
        
    Returns:
        str: Generated tweet without <s> and </s> tokens
    """
    tweet = ""
    current_context = context
    iteration = 0
    
    # Continue generating until we hit </s> or max length
    while iteration < max_length:
        # Get next word
        next_word = matrix.get_word_with_temperature(current_context, temperature=temperature)
        
        if next_word is None:
            break
            
        # If we encounter </s>, stop generating
        if next_word == '</s>':
            break
        
        # Append next word to tweet
        tweet += " " + next_word
            
        
        # Update context for next iteration
        current_context_tokens = current_context.context_tokens[1:] + [next_word]
        current_context = Context(context_tokens=current_context_tokens)
        iteration += 1
    
    return tweet.replace('<s>', '')


if __name__ == "__main__":
    
    # Process the Matteo Salvini tweets
    csv_path_salvini = "2022_pre_elections/Matteo Salvini.csv"
    csv_path_renzi = "2022_pre_elections/Matteo Renzi.csv"
    moby_dick_path = "MobyDick/moby-dick.txt"
    
    corpus = process_moby_dick_to_corpus(moby_dick_path)
    #corpus = process_tweets_to_corpus(csv_path_salvini)
    #corpus = process_tweets_to_corpus(csv_path_renzi)
    
    print("Corpus processed successfully. Number of sentences:", len(corpus))
    print("Generating n-grams...")
    ngrams_contexts, vocabulary = generate_ngrams(corpus, n=3)
    
    #save ngrams_contexts and vocabulary to a file
    with open('ngrams_contexts.txt', 'w') as f:
        for context in ngrams_contexts:
            f.write(str(context) + '\n')
    with open('vocabulary.txt', 'w') as f:
        for word in vocabulary:
            f.write(word + '\n')
    
    print("N-grams generated successfully. Number of contexts:", len(ngrams_contexts))
    print("Vocabulary size:", len(vocabulary))
    

    ngram_matrix = NgramProbabilityMatrix(vocabulary, ngrams_contexts)
    

    print("Start generating sentence from context...")
    length = 20
    ngrams_contexts = random.sample(ngrams_contexts, 5)
    
    # Moby Dick literature text
    for context in ngrams_contexts:
        generated_sentence = generate_sentence_from_context(context, ngram_matrix, length, temperature = 0.5, ngram_size=3)
        print("Generated sentence:", generated_sentence)
        print("-" * 50)


    print("Start generating tweet from context...")
    """
    #get all contexts that contain '<s>'
    contexts_with_start = [c for c in ngrams_contexts if '<s>' == c.context_tokens[0]]
    length = 100
    num_tweet = min(len(contexts_with_start), 3)
    for i in range(0,num_tweet):
        if contexts_with_start:
            random_context = random.choice(contexts_with_start)
            generated_tweet = generate_tweet(random_context, ngram_matrix, length, temperature=0, ngram_size=3)
            if(len(generated_tweet) < 1):
                break
            print("Generated tweet:", generated_tweet)
        else:
            print("No context with '<s>' token.")
    """