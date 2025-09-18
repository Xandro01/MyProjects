from nltk.corpus import semcor
import nltk
from nltk.corpus import wordnet as wn
from transformers import DistilBertTokenizer, DistilBertModel
import numpy as np
import random
# Scarica WordNet se non è già presente
nltk.download('wordnet')
# Assicurati di avere il corpus semcor installato
nltk.download('semcor')


import string


#A function that take in input a semcor sentence (context), the word we want to disambiguate in the context. The function have to:
# 1) get all sense of the target word (based on wordnet), for each sense: get a list of sense sentences from wordnet examples sentences and from sem cor corpus. After calla a function "getAverageSentenceWordEmbedding(sense_sentences List)" that return 
# an average embedding. A variable have to collect for each sense the average embedding list 
def get_sense_prediction(context, target_word):
    # Get all senses of the target word from WordNet
    senses = wn.synsets(target_word)
  
    # Initialize a list to store average embeddings for each sense
    sense_embeddings = []
    
    max_similarity = float('-inf')
    best_sense = None
    # Collect sense sentences from WordNet examples and SemCor
    for sense in senses:
        sense_sentences = []

        # Get sentences from SemCor that match the target word and sense
        semcor_sentences = get_sentences_for_sense(target_word, sense.name())
        sense_sentences.extend(semcor_sentences)
        
        #print(f"Found {len(sense_sentences)} sentences for sense { sense.name()}")
        # remove contxt from sense_sentences in order to avoid bias in the average embedding
        sense_sentences = [s for s in sense_sentences if s != context]     
        #print(f"Sense sentences {sense_sentences}" )
        # Skip this sense if no sentences found
        if not sense_sentences:
            print(f"No sentences found for sense {sense.name()}")
            continue
        
        # Calculate average embedding for this sense
        avg_embedding = getAverageSentenceWordEmbedding(sense_sentences, target_word)
        context_embedding = getAverageSentenceWordEmbedding([context], target_word)
        
        # Skip if embeddings couldn't be calculated
        if avg_embedding is None or context_embedding is None:
            print(f"Could not calculate embeddings for sense {sense.name()}, {context}")
            continue
        

        cosine_similarity = cosine_similarity_manual(avg_embedding.detach().numpy(), context_embedding.detach().numpy())
        print(f"Cosine similarity for sense {sense.name()}: {cosine_similarity:.4f}")
        if cosine_similarity > max_similarity:
            max_similarity = cosine_similarity.item()
            best_sense = sense.name()
    
    
    return  max_similarity, best_sense


# Function to get average embedding from a list of sentences that contain the target word in a specific sense
def getAverageSentenceWordEmbedding(sense_sentences, target_word):
    tokenizer = DistilBertTokenizer.from_pretrained('distilbert-base-uncased')
    model = DistilBertModel.from_pretrained('distilbert-base-uncased')
    embeddings = []
    for sentence in sense_sentences:
        
        
        words = sentence.split()
        cleaned_words = [word.strip(string.punctuation) for word in words 
                        if word.strip(string.punctuation)]
        sentence = ' '.join(cleaned_words)
        
        # inputs: sentence is beeing tokenized and converted to tensors where each token is represented by an ID (DistilBert Vocabulary)
        inputs = tokenizer(sentence, return_tensors='pt', padding=True, truncation=True)
        outputs = model(**inputs)
        
        # outputs.last_hidden_state contains the embeddings for each token in the sentence
        sentence_embedding = outputs.last_hidden_state
        
        sentence_tokens = tokenizer.tokenize(sentence)
        target_word_tokens = tokenizer.tokenize(target_word)

        # find the positions of the target word tokens in the sentence tokens
        target_positions = []
        for i in range(len(sentence_tokens) - len(target_word_tokens) + 1):
            if sentence_tokens[i:i+len(target_word_tokens)] == target_word_tokens:
                target_positions.extend(range(i, i+len(target_word_tokens)))
                break

        if target_positions:
            # Estrai gli embedding per le posizioni trovate
            target_word_embedding = sentence_embedding[0, target_positions, :].mean(dim=0)
            embeddings.append(target_word_embedding)
        
    return sum(embeddings) / len(embeddings) if embeddings else None


def cosine_similarity_manual(a, b):
    return (np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b)))


def get_sentences_for_sense(target_word, target_sense):
    
    sentences = []
    
    for sent in semcor.tagged_sents(tag='both'):
        sentence_words = []
        found_target = False
        
        for tree in sent:
            if tree.label() is not None and '.' in str(tree.label()):
                word_text = tree.leaves()[0] if tree.leaves() else ''
                #se es such non c'è sysnset associato allora continue
                if not hasattr(tree.label(), 'synset'):
                    continue
                
                sense_label = tree.label().synset().name()
                sentence_words.append(word_text)
                
                if word_text.lower() == target_word.lower() and sense_label == target_sense:
                    found_target = True
            else:
                word_text = tree.leaves()[0] if tree.leaves() else ''
                sentence_words.append(word_text)
        
        if found_target:
            sentences.append(' '.join(sentence_words))
    
    return sentences

# randomly extract 50 sentences from semcor corpus, for each sentence: 1) extract all polysemy NN terms (based on wordnet) in a list  2) randomly choose an element in the list and get the correct sense in the sentence 3) call the function get_sense_prediction(context, target_word) to get the best sense for the target word in the context
# return the accuracy of the WSD task (number of correct predictions (sense target compare to sense predicted) / 50)
def semcor_50_sentences_WSD_accuracy():
    semcor_tagged_sents = list(semcor.tagged_sents(tag='both'))
    correct_predictions = 0
    total_sentences = 50
    parsified_sentence = 0
    while parsified_sentence < total_sentences:
        # Get a random tagged sentence from semcor
        tagged_sent = random.choice(semcor_tagged_sents)
        
        # Create mapping of polysemous nouns to their senses
        polysemous_noun_sense_map = {}
        context_words = []
        
        for tree in tagged_sent:
            if hasattr(tree, 'label') and tree.label() is not None:
                if hasattr(tree.label(), 'synset'):
                    # This is a tagged word with sense annotation
                    word_text = tree.leaves()[0] if tree.leaves() else ''
                    
                    # Get the POS tag from the tree label
                    pos_tag = tree[0].label()
                    #print(f"Processing word: {word_text}, POS: {pos_tag}")
                    sense_label = tree.label().synset().name()
                    
                    context_words.append(word_text)
                    
                    # Check if it's a noun and polysemous
                    if pos_tag.startswith('NN') and len(wn.synsets(word_text)) > 1:
                        polysemous_noun_sense_map[word_text.lower()] = sense_label
                else:
                    # Word without sense annotation
                    word_text = tree.leaves()[0] if tree.leaves() else ''
                    context_words.append(word_text)
            else:
                # Simple word
                word_text = tree.leaves()[0] if tree.leaves() else ''
                context_words.append(word_text)
        
        context = ' '.join(context_words)
        if not polysemous_noun_sense_map:
            #print(f"No polysemous nouns found in sentence {i+1}. Skipping.")
            continue
        
        # Randomly choose a polysemous noun and its correct sense
        target_word = random.choice(list(polysemous_noun_sense_map.keys()))
        target_sense = polysemous_noun_sense_map[target_word]
        
        # Get the best sense prediction
        max_similarity, best_sense = get_sense_prediction(context, target_word)
        print(f"Sentence {parsified_sentence}: Context: {context}, Target Word: {target_word}, Correct Sense: {target_sense}, Predicted Sense: {best_sense}")
        parsified_sentence += 1
        if best_sense == target_sense:
            correct_predictions += 1
    
    accuracy = correct_predictions / parsified_sentence if parsified_sentence > 0 else 0
    return accuracy


if __name__ == "__main__":
    accuracy_secomr_execution = []
    for i in range(1):
        accuracy = semcor_50_sentences_WSD_accuracy()
        accuracy_secomr_execution.append(accuracy)
        
    print(f"Average accuracy over 10 executions: {np.mean(accuracy_secomr_execution):.4f}")